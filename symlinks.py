#!/usr/bin/env python3

import argparse
import os
from pathlib import Path

KNOWN_CONTAINER_PATHS = ".config".split()
IGNORED_FILES = ".git .gitignore .gitmodules .DS_Store .venv".split() + KNOWN_CONTAINER_PATHS

parser = argparse.ArgumentParser(description="simple tool to manage symbolic links.")
parser.add_argument(
    "-f", "--force", action="store_true", help="forcibly manage symbolic links."
)
parser.add_argument(
    "-d",
    "--dest",
    type=str,
    default=Path.home(),
    help="destination path. default to `%(default)s`.",
)
parser.add_argument(
    "action",
    choices=["create", "remove"],
    nargs="?",
    default="create",
    help="action for symbolic links. default to `%(default)s`.",
)
args = parser.parse_args()


def process(path, container_path=None):
    dest_path = Path(args.dest)
    if container_path:
        dest_path = dest_path / container_path
        if not dest_path.exists():
            dest_path.mkdir(parents=True)
    link_from = dest_path / path.name
    link_to = os.path.relpath(path, start=dest_path)
    if args.action == "create":
        if link_from.exists():
            if args.force:
                link_from.unlink()
            else:
                print(f"{link_from} already exists.")
                return
        print(f"Create link {link_from} to {link_to}...")
        link_from.symlink_to(link_to)
    else:
        if link_from.exists() and link_from.is_symlink():
            print(f"Remove link {link_from}...")
            link_from.unlink()


base_path = Path(__file__).parent

for path in base_path.glob(".*"):
    if not path.name in IGNORED_FILES:
        process(path)

for known_container_path_string in KNOWN_CONTAINER_PATHS:
    known_container_path = Path(known_container_path_string)
    container_path = base_path / known_container_path
    if container_path.is_dir():
        for path in container_path.glob("*"):
            process(path, container_path=known_container_path)
