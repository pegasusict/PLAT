from lib.sysutil import run

def apt_update() -> None:
    run(["apt-get", "-q", "update"])


def apt_upgrade() -> None:
    run(["apt-get", "-qy", "upgrade"])


def apt_autoremove() -> None:
    run(["apt-get", "-qqy", "autoremove"])


def apt_autoclean() -> None:
    run(["apt-get", "-qqy", "autoclean"])


def apt_install(*pkgs: str) -> None:
    run(["apt-get", "-qy", "install"] + list(pkgs))
