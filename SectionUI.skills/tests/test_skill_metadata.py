from __future__ import annotations

import json
import re
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = SKILL_ROOT.parent
SKILL_PATH = SKILL_ROOT / "SKILL.md"
UPDATE_PATH = SKILL_ROOT / "UPDATE.md"
VERSION_PATH = SKILL_ROOT / "VERSION.md"
REFERENCES_ROOT = SKILL_ROOT / "references"
ISSUE_GUIDE_PATH = SKILL_ROOT / "ISSUE_GUIDE.md"
SCRIPT_ROOT = SKILL_ROOT / "scripts"
sys.path.insert(0, str(SCRIPT_ROOT))

import package_skill  # noqa: E402
import reference_compat  # noqa: E402
import sync_release_version  # noqa: E402
import verify_skill_package  # noqa: E402


class SkillMetadataTests(unittest.TestCase):
    def setUp(self) -> None:
        self.skill_text = SKILL_PATH.read_text(encoding="utf-8")

    def test_skill_exposes_single_current_version(self) -> None:
        metadata_version = re.search(r'version:\s*"(\d+\.\d+\.\d+)"', self.skill_text)
        visible_version = re.search(r"Current local skill version:\s*`v(\d+\.\d+\.\d+)`", self.skill_text)
        hidden_version = re.search(r"<!-- version:\s*(\d+\.\d+\.\d+)\s*-->", self.skill_text)
        update_version = re.search(r"Current version:\s*`v(\d+\.\d+\.\d+)`", UPDATE_PATH.read_text(encoding="utf-8"))
        version_doc = re.search(r"Current version:\s*`v(\d+\.\d+\.\d+)`", VERSION_PATH.read_text(encoding="utf-8"))

        self.assertIsNotNone(metadata_version)
        self.assertIsNotNone(visible_version)
        self.assertIsNotNone(hidden_version)
        self.assertIsNotNone(update_version)
        self.assertIsNotNone(version_doc)
        self.assertEqual(metadata_version.group(1), visible_version.group(1))
        self.assertEqual(metadata_version.group(1), hidden_version.group(1))
        self.assertEqual(metadata_version.group(1), update_version.group(1))
        self.assertEqual(metadata_version.group(1), version_doc.group(1))

    def test_routing_indexes_exist_and_cover_core_topics(self) -> None:
        task_map = (REFERENCES_ROOT / "TASK_MAP.md").read_text(encoding="utf-8")
        api_map = (REFERENCES_ROOT / "API_MAP.md").read_text(encoding="utf-8")
        index = (REFERENCES_ROOT / "INDEX.md").read_text(encoding="utf-8")

        for fragment in [
            "data-driven-best-practices.md",
            "manager-transaction-recipes.md",
            "row-mutation-recipes.md",
            "selection-ownership-recipes.md",
            "swiftui-hosting-recipes.md",
        ]:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, task_map)
                self.assertIn(fragment, index)

        for fragment in ["SKCManager", "SKCSingleTypeSection", "SKSelectionState", "SKCollectionFlowLayout"]:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, api_map)

    def test_reference_compatibility_checks_pass(self) -> None:
        issues = reference_compat.run_checks(SKILL_ROOT, REPO_ROOT)
        self.assertEqual([], issues)

    def test_task_map_preserves_core_intent_routes(self) -> None:
        task_map = (REFERENCES_ROOT / "TASK_MAP.md").read_text(encoding="utf-8").lower()

        expected_routes = {
            "visible cell mutation": "data-driven-best-practices.md",
            "data binding strategy": "data-driven-best-practices.md",
            "high-frequency progress": "data-driven-best-practices.md",
            "stable cell view model": "reactive-binding-recipes.md",
            "subscribe(models:)": "reactive-binding-recipes.md",
            "plugin priority": "layout-plugin-execution-recipes.md",
            "custom forward": "layout-plugin-execution-recipes.md",
            "stale cached size": "safe-size-measurement-recipes.md",
        }

        for keyword, reference in expected_routes.items():
            with self.subTest(keyword=keyword):
                self.assertIn(keyword, task_map)
                self.assertIn(reference, task_map)

    def test_package_skill_includes_build_info_and_routes(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "sectionui.skill.zip"
            payload = package_skill.package_skill(REPO_ROOT, SKILL_ROOT, output, "v0.0.0-test")

            self.assertTrue(output.is_file())
            self.assertEqual(payload["buildInfo"]["name"], "sectionui")
            self.assertEqual(payload["buildInfo"]["releaseTag"], "v0.0.0-test")

            with zipfile.ZipFile(output) as archive:
                names = set(archive.namelist())
                self.assertIn("SKILL.md", names)
                self.assertIn("UPDATE.md", names)
                self.assertIn("VERSION.md", names)
                self.assertIn("BUILD_INFO.json", names)
                self.assertIn("ISSUE_GUIDE.md", names)
                self.assertIn("references/TASK_MAP.md", names)
                self.assertIn("references/API_MAP.md", names)
                self.assertIn("scripts/reference_compat.py", names)
                for removed in reference_compat.REMOVED_REFERENCES:
                    self.assertNotIn(f"references/{removed}", names)
                self.assertNotIn("SectionUI.skills/SKILL.md", names)
                build_info = json.loads(archive.read("BUILD_INFO.json").decode("utf-8"))
                self.assertEqual(build_info["name"], "sectionui")

    def test_verify_skill_package_release_preflight_passes(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "sectionui.skill.zip"
            payload = verify_skill_package.verify(REPO_ROOT, SKILL_ROOT, output, "v0.0.0-test")

            self.assertTrue(payload["ok"])
            self.assertEqual([], payload["issues"])
            self.assertTrue(output.is_file())
            self.assertEqual("v0.0.0-test", payload["buildInfo"]["releaseTag"])

    def test_feedback_workflow_is_documented(self) -> None:
        issue_guide = ISSUE_GUIDE_PATH.read_text(encoding="utf-8")

        for fragment in [
            "sectionui-reference-api.yml",
            "sectionui-usage-recipe.yml",
            "sectionui-example-template.yml",
            "sectionui-skill-packaging.yml",
            "sectionui-framework-behavior.yml",
            "Redact private data",
            "gh issue create --repo linhay/SectionKit",
        ]:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, issue_guide)

        for fragment in ["ISSUE_GUIDE.md", "Feedback Workflow", ".github/ISSUE_TEMPLATE/"]:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, self.skill_text)

    def test_update_and_version_docs_are_present(self) -> None:
        update_text = UPDATE_PATH.read_text(encoding="utf-8")
        version_text = VERSION_PATH.read_text(encoding="utf-8")

        for fragment in ["sectionui.skill.zip", "BUILD_INFO.json", "VERSION.md", "SKILL.md"]:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, update_text)
        self.assertIn("Current version:", version_text)

    def test_sync_release_version_normalizes_tags(self) -> None:
        self.assertEqual(sync_release_version.normalize_version("2.5.4"), ("2.5.4", "v2.5.4"))
        self.assertEqual(sync_release_version.normalize_version("refs/tags/v2.5.4"), ("2.5.4", "v2.5.4"))
        with self.assertRaises(ValueError):
            sync_release_version.normalize_version("2.5")


if __name__ == "__main__":
    unittest.main()
