from pathlib import Path
import time

from lib.logging import debug

def delete_by_patterns(root: str | Path, patterns: list[str]) -> None:
    """Delete files matching specified patterns within a directory."""
    root = Path(root)

    for pattern in patterns:
        for p in root.rglob(pattern):
            try:
                p.unlink()
                debug(f"Deleted {p}")
            except Exception:
                pass


def delete_old_logs(path: str | Path, days: int) -> None:
    """Delete log files older than a specified number of days."""
    cutoff = time.time() - days * 86400

    for p in Path(path).rglob("*.log"):
        if p.stat().st_mtime < cutoff:
            try:
                p.unlink()
                debug(f"Removed log {p}")
            except Exception:
                pass