#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import tempfile
import zipfile
from dataclasses import asdict, dataclass
from pathlib import Path

import package_skill
import reference_compat


REQUIRED_ARCHIVE_ENTRIES = {
    "SKILL.md",
    "UPDATE.md",
    "VERSION.md",
    "BUILD_INFO.json",
    "ISSUE_GUIDE.md",
    "agents/openai.yaml",
    "references/TASK_MAP.md",
    "references/API_MAP.md",
    "references/INDEX.md",
    "references/data-driven-best-practices.md",
    "references/layout-plugin-execution-recipes.md",
    "scripts/package_skill.py",
    "scripts/reference_compat.py",
    "scripts/verify_skill_package.py",
}
REMOVED_ARCHIVE_ENTRIES = {f"references/{name}" for name in reference_compat.REMOVED_REFERENCES}
MAINTENANCE_COMMANDS = {
    "scripts/package_skill.py",
    "scripts/sync_release_version.py",
    "scripts/reference_compat.py",
    "scripts/verify_skill_package.py",
    "unittest discover -s SectionUI.skills/tests",
}


@dataclass(frozen=True)
class Issue:
    code: str
    path: str
    detail: str


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def check_maintenance_docs(repo_root: Path, skill_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    docs = {
        "README.md": read_text(repo_root / "README.md"),
        "SectionUI.skills/SKILL.md": read_text(skill_root / "SKILL.md"),
    }
    for command in sorted(MAINTENANCE_COMMANDS):
        for path, text in docs.items():
            if command not in text:
                issues.append(Issue("maintenance_command_missing", path, command))
    return issues


def check_archive(archive_path: Path, expected_version: str, expected_release_tag: str | None) -> list[Issue]:
    issues: list[Issue] = []
    with zipfile.ZipFile(archive_path) as archive:
        names = set(archive.namelist())
        for entry in sorted(REQUIRED_ARCHIVE_ENTRIES):
            if entry not in names:
                issues.append(Issue("archive_entry_missing", str(archive_path), entry))
        for entry in sorted(REMOVED_ARCHIVE_ENTRIES):
            if entry in names:
                issues.append(Issue("removed_archive_entry_present", str(archive_path), entry))
        for name in sorted(names):
            if "__pycache__" in name or name.endswith(".pyc") or Path(name).name == ".DS_Store":
                issues.append(Issue("generated_file_packaged", str(archive_path), name))
        if "BUILD_INFO.json" in names:
            build_info = json.loads(archive.read("BUILD_INFO.json").decode("utf-8"))
            if build_info.get("name") != "sectionui":
                issues.append(Issue("build_info_name_mismatch", "BUILD_INFO.json", str(build_info.get("name"))))
            if build_info.get("version") != expected_version:
                issues.append(Issue("build_info_version_mismatch", "BUILD_INFO.json", str(build_info.get("version"))))
            if expected_release_tag and build_info.get("releaseTag") != expected_release_tag:
                issues.append(Issue("build_info_release_tag_mismatch", "BUILD_INFO.json", str(build_info.get("releaseTag"))))
    return issues


def verify(repo_root: Path, skill_root: Path, output: Path, release_tag: str | None = None) -> dict[str, object]:
    issues: list[Issue] = []
    reference_issues = reference_compat.run_checks(skill_root, repo_root)
    issues.extend(Issue(issue.code, issue.path, issue.detail) for issue in reference_issues)
    issues.extend(check_maintenance_docs(repo_root, skill_root))

    payload = package_skill.package_skill(repo_root, skill_root, output, release_tag)
    expected_version = package_skill.read_skill_version(skill_root)
    issues.extend(check_archive(output, expected_version, release_tag))
    return {
        "ok": not issues,
        "output": payload["output"],
        "buildInfo": payload["buildInfo"],
        "issues": [asdict(issue) for issue in issues],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify SectionUI skill release package.")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--skill-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path)
    parser.add_argument("--release-tag")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    output = args.output or Path(tempfile.gettempdir()) / "sectionui.skill.zip"
    payload = verify(args.repo_root.resolve(), args.skill_root.resolve(), output.resolve(), args.release_tag)

    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    elif payload["issues"]:
        for issue in payload["issues"]:
            print(f"{issue['code']}: {issue['path']}: {issue['detail']}")
    else:
        print(f"SectionUI skill package verified: {payload['output']}")
    return 0 if payload["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
