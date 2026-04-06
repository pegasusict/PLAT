import os
import sys
import subprocess
from pathlib import Path

from lib.logging import info, debug, crit

DEBUG = True


# ---------------------------------------------------------------------
# privilege
# ---------------------------------------------------------------------

def require_root()-> None:
    """Check if the script is running as root, and if not, restart it with sudo."""
    if os.geteuid() != 0:
        info("Restarting with sudo...")
        os.execvp("sudo", ["sudo", sys.executable] + sys.argv)


# ---------------------------------------------------------------------
# command execution
# ---------------------------------------------------------------------

def run(cmd: str | list[str], quiet: bool=False) -> str:
    """Run a command and return its output. If the command fails, print the error and exit."""
    if isinstance(cmd, str):
        shell = True
    else:
        shell = False

    debug(f"EXEC: {cmd}")

    result = subprocess.run(
        cmd,
        shell=shell,
        text=True,
        capture_output=True
    )

    if result.stdout and not quiet:
        debug(result.stdout.strip())

    if result.returncode != 0:
        crit(result.stderr.strip())

    return result.stdout


def reboot_required() -> bool:
    """Check if a reboot is required by looking for the presence of the /var/run/reboot-required file."""
    return Path("/var/run/reboot-required").exists()
