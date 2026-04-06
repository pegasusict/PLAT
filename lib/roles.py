import yaml
from pathlib import Path
from enum import StrEnum, auto
from typing import Callable, TypedDict, NotRequired, TypeVar, cast

from lib import run, info, apt_install, apt_update

T = TypeVar("T")
CFG_PATH = Path(__file__).resolve().parent.parent / "config"


class Role(StrEnum):
    """Defines system roles for provisioning. Each role corresponds to a set of 
    packages, snaps, PPAs, and services defined in a YAML configuration file."""
    BASIC = auto()          # Basic system with common utilities

    WS = auto()             # Workstation with desktop environment and apps   
    ZEUS = auto()           # Zeus WorkStation with extra tools for development and security 

    SERVER = auto()         # Server basics with webmin
    LXCHOST = auto()        # LXC host for running containers
    BACKUPSERVER = auto()   # Backup server with borg and rsnapshot

    CONTAINER = auto()      # Container role for LXC containers
    NAS = auto()            # Network Attached Storage role with samba
    PXE = auto()            # PXE boot server for network booting
    ROUTER = auto()         # Router role with firewall and routing tools
    WEB = auto()            # Web server role with nginx and certbot
    DB = auto()             # Database server role with mariadb and phpmyadmin
    X11 = auto()            # X11 role for graphical interface
    HONEY = auto()          # Honey pot role for security testing


def get_role(role: str | Role) -> Role:
    """Convert a string to a Role enum, or return if it's already a Role."""
    if isinstance(role, Role):
        return role
    try:
        return Role[role.upper()]
    except KeyError:
        raise ValueError(f"Unknown role: {role}")


class SnapSpec(TypedDict):
    name: str
    channel: NotRequired[str]
    classic: NotRequired[bool]


class RoleConfig(TypedDict):
    depends: NotRequired[list[str]]
    ppas: NotRequired[list[str]]
    packages: NotRequired[list[str]]
    snaps: NotRequired[list[SnapSpec]]
    services: NotRequired[list[str]]


class ProvisionPlan(TypedDict):
    ppas: set[str]
    packages: set[str]
    snaps: dict[str, SnapSpec]
    services: set[str]


class RoleManager:
    """
    Manages system roles and their configurations based on a YAML file.
    The YAML file should define roles and their dependencies, packages, 
    snaps, PPAs, and services.
    
    attributes:
        enable(role): Enable a role by name, resolving dependencies.
        show_roles(): Display the currently enabled roles.
        provision(): Apply all configurations for the enabled roles.
        build_plan(): Build a complete provisioning plan based on the enabled roles.
    """
    
    enabled_roles: set[Role]

    def __init__(self, config_file: str | Path=Path("roles.yaml"), dry_run: bool = False) -> None:
        config_file = Path(config_file)
        self.config = yaml.safe_load(Path(CFG_PATH / config_file).read_text())
        self.enabled_roles = set()
        self.dry_run = dry_run
        self._validate_roles()

    def build_plan(self) -> ProvisionPlan:
        """Build a complete provisioning plan based on the enabled roles."""
        plan: ProvisionPlan = {
            "ppas": set(),
            "packages": set(),
            "snaps": {},
            "services": set(),
        }

        for role in self.enabled_roles:
            role_cfg: RoleConfig = cast(RoleConfig, self.config.get(role.value, {}))

            for ppa in role_cfg.get("ppas", []):
                plan["ppas"].add(ppa)

            for pkg in role_cfg.get("packages", []):
                plan["packages"].add(pkg)

            for snap in role_cfg.get("snaps", []):
                plan["snaps"][snap["name"]] = snap

            for service in role_cfg.get("services", []):
                plan["services"].add(service)

        return plan

    def _run(self, cmd: list[str]) -> None:
        """Run a command, respecting dry-run mode."""
        if self.dry_run:
            info("[dry-run] " + " ".join(cmd))
        else:
            run(cmd)

    def _apt_install(self, *pkgs: str) -> None:
        """Install packages using apt, respecting dry-run mode."""
        if self.dry_run:
            info("[dry-run] apt install " + " ".join(pkgs))
        else:
            apt_install(*pkgs)

    def _validate_roles(self):
        """Validate that all roles and dependencies in the config are defined. Should be called during initialization."""
        for role, cfg in self.config.items():
            role = get_role(role)
            for dep in cfg.get("depends", []):
                dep = get_role(dep)
                if dep.value.upper() not in self.config:
                    raise ValueError(f"{role} depends on undefined role {dep}")

    def _resolve_roles(self, selected_roles: list[str | Role]) -> list[Role]:
        """Resolve roles with dependencies using a deterministic topological sort."""
        resolved: list[Role] = []
        visiting: set[Role] = set()
        visited: set[Role] = set()

        def visit(role: Role) -> None:
            if role in visited:
                return
            if role in visiting:
                raise ValueError(f"Cyclic dependency detected at role: {role.value}")

            visiting.add(role)

            role_cfg = cast(RoleConfig, self.config.get(role.value, {}))
            for dep in sorted(role_cfg.get("depends", [])):  # deterministic order
                visit(get_role(dep))

            visiting.remove(role)
            visited.add(role)
            resolved.append(role)

        # ensure deterministic input order
        for role in sorted(map(get_role, selected_roles), key=lambda r: r.value):
            visit(role)

        return resolved

    def enable(self, role: str | Role) -> None:
        """Enable a role by name."""
        resolved = self._resolve_roles([role])
        self.enabled_roles.update(resolved)
        info(f"Enabled roles: {', '.join(r.value for r in self.enabled_roles)}")

    def _apply(self, key: str, handler: Callable[..., None]) -> None:
        """
        Apply a configuration key for all enabled roles.

        key: YAML key to read (packages, snaps, ppas, ...)
        handler: function(item) that performs the action
        """
        for role in self.enabled_roles:
            role_cfg = self.config.get(role.value, {})

            for item in role_cfg.get(key, []):
                handler(item)

    def _add_ppas(self, plan: ProvisionPlan) -> None:
        """Add PPAs from all enabled roles."""
        ppas:list[str] = sorted(set(plan["ppas"]))

        for ppa in ppas:
            info(f"Adding PPA {ppa}")
            self._run(["add-apt-repository", "-y", ppa])

    def _install_snaps(self, plan: ProvisionPlan) -> None:
        """Install snaps from all enabled roles."""
        snaps_dict: dict[str, SnapSpec] = {snap["name"]: snap for snap in plan["snaps"].values()}

        for snap in snaps_dict.values():
            snap_name: str = snap["name"]
            cmd: list[str] = ["snap", "install", snap_name]

            if "channel" in snap:
                cmd += ["--channel", snap["channel"]]

            if snap.get("classic", False):
                cmd.append("--classic")

            info(f"Installing snap {snap_name}")
            self._run(cmd)

    def _install_packages(self, plan: ProvisionPlan) -> None:
        """Install packages from all enabled roles."""
        pkgs: list[str] = sorted(set(plan["packages"]))

        if pkgs:
            info(f"Installing {len(pkgs)} packages")
            self._apt_install(*pkgs)

    def _enable_services(self, plan: ProvisionPlan) -> None:
        """Enable services from all enabled roles."""
        services:list[str] = sorted(set(plan["services"]))

        for service in services:
            info(f"Enabling service {service}")
            self._run(["systemctl", "enable", "--now", service])

    def show_roles(self):
        """Display the currently enabled roles."""
        info("Active roles: " + ", ".join(sorted(role.value for role in self.enabled_roles)))

    def provision(self) -> None:
        """Apply all configurations for the enabled roles. Should be called after all desired roles have been enabled."""
        if self.dry_run:
            info("=== DRY RUN MODE ===")

        self.show_roles()

        plan = self.build_plan()
        
        self._add_ppas(plan)
        apt_update()
        
        self._install_packages(plan)
        self._install_snaps(plan)
        self._enable_services(plan)
