#!/usr/bin/env python3
import argparse

from lib import (
    require_root, 
    info, 
    mkdir, 
    copy, 
    apt_update, 
    apt_upgrade, 
    apt_install, 
    apt_autoremove, 
    apt_autoclean, 
    delete_by_patterns, 
    delete_old_logs, 
    reboot_required,
    get_role,
    Role,
    RoleManager,
)

def parse_args() -> tuple(list[str], bool):
    """Parse command-line arguments for the bootstrap script."""
    parser = argparse.ArgumentParser(description="Provision system roles")

    parser.add_argument("roles", nargs="*", help="Roles to enable")
    parser.add_argument("--dry-run", action="store_true", help="Run without executing commands")

    args = parser.parse_args()
    return args.roles, args.dry_run

def main() -> None:
    require_root()

    info("Starting bootstrap")

    chosen_roles:list[str]
    dry_run:bool
    chosen_roles, dry_run = parse_args()
    role_manager = RoleManager(dry_run=dry_run)
    for role_name in chosen_roles:
        role = get_role(role_name)
        if role:
            role_manager.enable(role)
        else:
            info(f"Unknown role: {role_name}")
    role_manager.provision()

    mkdir("/usr/local/bin")

    if Role.BACKUPSERVER in role_manager.enabled_roles:
        info("Injecting network interfaces")
        copy("templates/lxchost_interfaces.txt",
             "/etc/network/interfaces")

    info("Copying apt sources")
    copy("./base_files/apt/base.list","/etc/apt/sources.list.d/base.list")

    info("Updating apt")
    apt_update()

    info("Upgrading packages")
    apt_upgrade()

    info("Installing utilities")
    apt_install("trash-cli")

    info("Cleaning packages")
    apt_autoremove()
    apt_autoclean()

    info("Cleaning temp files")
    delete_by_patterns("/home",["*.tmp", "*.temp", "*.swp", "*~", "*.bak"])
    delete_old_logs("/var/log", 30)

    if reboot_required():
        info("Reboot required")
    else:
        info("No reboot required")


if __name__ == "__main__":
    main()