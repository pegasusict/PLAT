from pathlib import Path
import shutil

from lib.logging import debug


def mkdir(path: str | Path) -> None:
    Path(path).mkdir(parents=True, exist_ok=True)


def copy(src: str | Path, dst: str | Path) -> None:
    debug(f"Copy {src} -> {dst}")
    shutil.copy(src, dst)


def add_line_if_missing(line: str, file: str | Path) -> None:
    p = Path(file)

    if not p.exists():
        p.write_text(line + "\n")
        return

    content = p.read_text()

    if line not in content:
        with p.open("a") as f:
            f.write(line + "\n")