import sys
from datetime import datetime

from lib.sysutil import DEBUG

# ---------------------------------------------------------------------
# logging
# ---------------------------------------------------------------------

def _ts() -> str:
    """Return current timestamp as a string."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def info(msg: str) -> None:
    """Print an informational message with timestamp."""
    print(f"{_ts()} [INFO]  {msg}")


def debug(msg: str) -> None:
    """Print a debug message with timestamp if DEBUG is enabled."""
    if DEBUG:
        print(f"{_ts()} [DEBUG] {msg}")


def warn(msg: str) -> None:
    """Print a warning message with timestamp."""
    print(f"{_ts()} [WARN]  {msg}")


def crit(msg: str) -> None:
    """Print a critical message with timestamp and exit."""
    print(f"{_ts()} [CRIT]  {msg}", file=sys.stderr)
    sys.exit(1)

