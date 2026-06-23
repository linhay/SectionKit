#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path


ROUTER_FILES = ["SKILL.md", "references/TASK_MAP.md", "references/API_MAP.md", "references/INDEX.md"]
REMOVED_REFERENCES = {"plugins.md", "layout-plugins.md", "advanced-sections.md", "MISSING_FEATURES.md", "manager.md", "cell.md", "decorations.md", "scroll.md", "pin.md", "page.md", "reactive.md", "performance.md", "section-advanced.md", "section-advanced-2.md", "section-best-practices.md", "section-styling.md", "section-events.md", "section-data-operations.md"}
CORE_DOCS_WITH_CONTENTS = {
    "data-driven-best-practices.md",
    "reactive-binding-recipes.md",
    "layout-plugin-execution-recipes.md",
}
CORE_ROUTES = {
    "visible cell mutation": "data-driven-best-practices.md",
    "data binding strategy": "data-driven-best-practices.md",
    "subscribe(models:)": "reactive-binding-recipes.md",
    "skbinding": "reactive-binding-recipes.md",
    "plugin priority": "layout-plugin-execution-recipes.md",
    "custom forward": "layout-plugin-execution-recipes.md",
    "stale cached size": "safe-size-measurement-recipes.md",
    "section index": "index-title-recipes.md",
}
CRITICAL_API_SYMBOLS = {
    "SKCManager": r"\bSKCManager\b",
    "SKCSingleTypeSection": r"\bSKCSingleTypeSection\b",
    "SKSelectionState": r"\bSKSelectionState\b",
    "SKCollectionFlowLayout": r"\bSKCollectionFlowLayout\b",
    "SKBindingKey": r"\bSKBindingKey\b",
    "SKCLayoutPlugins.Mode": r"SKCLayoutPlugins\.Mode",
    "SKCPluginAdjustAttributes": r"\bSKCPluginAdjustAttributes\b",
    "SKCPluginLayoutAttributesForElementsForward": r"\bSKCPluginLayoutAttributesForElementsForward\b",
    "subscribe(models:)": r"subscribe\(models",
}
API_SYMBOL_PATTERN = re.compile(r"\b(?:SK|STC)[A-Za-z0-9_]+\b")


@dataclass(frozen=True)
class Issue:
    code: str
    path: str
    detail: str


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def markdown_files(root: Path) -> list[Path]:
    return sorted(
        path
        for path in root.rglob("*.md")
        if "__pycache__" not in path.parts and path.name != ".DS_Store"
    )


def source_text(repo_root: Path) -> str:
    sources = repo_root / "Sources"
    return "\n".join(read_text(path) for path in sorted(sources.rglob("*.swift")))


def is_simple_reference_token(token: str) -> bool:
    if "*" in token or " " in token or '"' in token or "'" in token:
        return False
    return bool(re.fullmatch(r"(references/)?[-A-Za-z0-9_./]+\.md|ISSUE_GUIDE\.md", token))


def resolve_reference(skill_root: Path, source: Path, target: str) -> Path | None:
    target = target.strip()
    if not is_simple_reference_token(target):
        return None
    if target == "ISSUE_GUIDE.md":
        return skill_root / target
    if target.startswith("references/"):
        return skill_root / target
    if source.name in {"SKILL.md", "TASK_MAP.md", "API_MAP.md", "INDEX.md"}:
        return skill_root / "references" / target
    return source.parent / target


def referenced_targets(text: str, router_mode: bool) -> list[str]:
    targets = re.findall(r"\[[^\]]+\]\(([^)#]+\.md)(?:#[^)]+)?\)", text)
    if router_mode:
        targets.extend(re.findall(r"\x60([^\x60]+\.md)\x60", text))
    return targets


def check_reference_links(skill_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    router_paths = {skill_root / rel for rel in ROUTER_FILES}
    paths = [*router_paths, *markdown_files(skill_root / "references")]
    for path in sorted(set(paths)):
        if not path.is_file():
            issues.append(Issue("missing_router_file", str(path.relative_to(skill_root)), "required router file is missing"))
            continue
        router_mode = path in router_paths
        for target in referenced_targets(read_text(path), router_mode):
            if Path(target).name in REMOVED_REFERENCES:
                issues.append(Issue("removed_reference_used", str(path.relative_to(skill_root)), target))
            resolved = resolve_reference(skill_root, path, target)
            if resolved is not None and not resolved.is_file():
                issues.append(Issue("missing_reference", str(path.relative_to(skill_root)), target))
    return issues


def check_index_entries(skill_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    index = read_text(skill_root / "references" / "INDEX.md")
    listed = set(re.findall(r"\x60([^\x60]+\.md)\x60", index))
    for removed in REMOVED_REFERENCES:
        if removed in listed:
            issues.append(Issue("removed_reference_indexed", "references/INDEX.md", removed))
    for required in CORE_DOCS_WITH_CONTENTS:
        if required not in listed:
            issues.append(Issue("core_reference_not_indexed", "references/INDEX.md", required))
    return issues


def check_core_doc_contents(skill_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    for name in sorted(CORE_DOCS_WITH_CONTENTS):
        path = skill_root / "references" / name
        if not path.is_file():
            issues.append(Issue("missing_core_reference", str(path.relative_to(skill_root)), name))
            continue
        if "## Contents" not in read_text(path):
            issues.append(Issue("missing_contents", str(path.relative_to(skill_root)), "core reference should expose a table of contents"))
    return issues


def check_core_routes(skill_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    task_map = read_text(skill_root / "references" / "TASK_MAP.md").lower()
    for keyword, expected_ref in CORE_ROUTES.items():
        if keyword.lower() not in task_map:
            issues.append(Issue("missing_route_keyword", "references/TASK_MAP.md", keyword))
        if expected_ref.lower() not in task_map:
            issues.append(Issue("missing_route_reference", "references/TASK_MAP.md", expected_ref))
    return issues


def check_api_symbols(skill_root: Path, repo_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    api_map = read_text(skill_root / "references" / "API_MAP.md")
    sources = source_text(repo_root)
    for symbol, source_pattern in CRITICAL_API_SYMBOLS.items():
        if symbol not in api_map:
            issues.append(Issue("api_map_missing_symbol", "references/API_MAP.md", symbol))
        if not re.search(source_pattern, sources):
            issues.append(Issue("source_missing_symbol", "Sources", symbol))
    return issues


def check_api_map_source_drift(skill_root: Path, repo_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    api_map = read_text(skill_root / "references" / "API_MAP.md")
    sources = source_text(repo_root)
    declared_symbols = sorted(set(API_SYMBOL_PATTERN.findall(api_map)))
    for symbol in declared_symbols:
        if not re.search(r"\b" + re.escape(symbol) + r"\b", sources):
            issues.append(Issue("api_map_symbol_missing_from_source", "references/API_MAP.md", symbol))
    return issues


def check_api_references_indexed(skill_root: Path) -> list[Issue]:
    issues: list[Issue] = []
    api_map = read_text(skill_root / "references" / "API_MAP.md")
    index = read_text(skill_root / "references" / "INDEX.md")
    indexed = set(re.findall(r"\x60([^\x60]+\.md)\x60", index))
    api_references = set(re.findall(r"\x60([^\x60]+\.md)\x60", api_map))
    for reference in sorted(api_references):
        if reference not in indexed:
            issues.append(Issue("api_reference_not_indexed", "references/API_MAP.md", reference))
    return issues


def run_checks(skill_root: Path, repo_root: Path) -> list[Issue]:
    return [
        *check_reference_links(skill_root),
        *check_index_entries(skill_root),
        *check_core_doc_contents(skill_root),
        *check_core_routes(skill_root),
        *check_api_symbols(skill_root, repo_root),
        *check_api_map_source_drift(skill_root, repo_root),
        *check_api_references_indexed(skill_root),
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate SectionUI skill reference compatibility.")
    parser.add_argument("--skill-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    issues = run_checks(args.skill_root.resolve(), args.repo_root.resolve())
    payload = {"ok": not issues, "issues": [asdict(issue) for issue in issues]}
    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    elif issues:
        for issue in issues:
            print(f"{issue.code}: {issue.path}: {issue.detail}")
    else:
        print("SectionUI skill references are compatible.")
    return 1 if issues else 0


if __name__ == "__main__":
    raise SystemExit(main())
