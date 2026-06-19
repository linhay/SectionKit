#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import zipfile
from datetime import datetime, timezone
from pathlib import Path


def git_value(root: Path, *args: str) -> str:
    result = subprocess.run(["git", *args], cwd=root, capture_output=True, text=True, check=True)
    return result.stdout.strip()


def read_skill_version(skill_root: Path) -> str:
    text = (skill_root / "SKILL.md").read_text(encoding="utf-8")
    in_metadata = False
    for line in text.splitlines():
        stripped = line.strip()
        if stripped == "metadata:":
            in_metadata = True
            continue
        if in_metadata and stripped.startswith("version:"):
            return stripped.partition(":")[2].strip().strip('"')
        if in_metadata and line and not line.startswith(" "):
            in_metadata = False
    raise ValueError("Could not find metadata.version in SKILL.md")


def build_info(repo_root: Path, skill_root: Path, release_tag: str | None = None) -> dict[str, object]:
    full_hash = git_value(repo_root, "rev-parse", "HEAD")
    dirty_status = git_value(repo_root, "status", "--short")
    tag = release_tag or git_value(repo_root, "describe", "--tags", "--always", "--dirty")
    return {
        "name": "sectionui",
        "version": read_skill_version(skill_root),
        "releaseTag": tag,
        "git": {
            "commit": full_hash,
            "shortCommit": full_hash[:7],
            "dirty": bool(dirty_status),
        },
        "builtAt": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    }


def should_skip(path: Path) -> bool:
    parts = set(path.parts)
    return (
        "__pycache__" in parts
        or ".DS_Store" in parts
        or path.name.endswith(".pyc")
        or path.name == ".pytest_cache"
    )


def package_skill(repo_root: Path, skill_root: Path, output: Path, release_tag: str | None = None) -> dict[str, object]:
    info = build_info(repo_root, skill_root, release_tag)
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        output.unlink()

    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(skill_root.rglob("*")):
            rel_path = path.relative_to(skill_root)
            if not path.is_file() or should_skip(rel_path):
                continue
            archive.write(path, rel_path.as_posix())
        archive.writestr("BUILD_INFO.json", json.dumps(info, ensure_ascii=False, indent=2) + "\n")

    return {"output": str(output), "buildInfo": info}


def main() -> int:
    parser = argparse.ArgumentParser(description="Package SectionUI skill with build metadata.")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--skill-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path, default=Path("sectionui.skill.zip"))
    parser.add_argument("--release-tag", help="Release tag to record in BUILD_INFO.json")
    parser.add_argument("--json", action="store_true", help="Print machine-readable package metadata")
    args = parser.parse_args()

    payload = package_skill(args.repo_root.resolve(), args.skill_root.resolve(), args.output.resolve(), args.release_tag)
    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print(f"Packaged {payload['output']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
