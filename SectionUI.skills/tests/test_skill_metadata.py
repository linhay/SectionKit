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
REFERENCES_ROOT = SKILL_ROOT / "references"
ISSUE_GUIDE_PATH = SKILL_ROOT / "ISSUE_GUIDE.md"
SCRIPT_ROOT = SKILL_ROOT / "scripts"
sys.path.insert(0, str(SCRIPT_ROOT))

import package_skill  # noqa: E402
import sync_release_version  # noqa: E402


class SkillMetadataTests(unittest.TestCase):
    def setUp(self) -> None:
        self.skill_text = SKILL_PATH.read_text(encoding="utf-8")

    def test_skill_exposes_single_current_version(self) -> None:
        metadata_version = re.search(r'version:\s*"(\d+\.\d+\.\d+)"', self.skill_text)
        visible_version = re.search(r"Current local skill version:\s*`v(\d+\.\d+\.\d+)`", self.skill_text)
        hidden_version = re.search(r"<!-- version:\s*(\d+\.\d+\.\d+)\s*-->", self.skill_text)

        self.assertIsNotNone(metadata_version)
        self.assertIsNotNone(visible_version)
        self.assertIsNotNone(hidden_version)
        self.assertEqual(metadata_version.group(1), visible_version.group(1))
        self.assertEqual(metadata_version.group(1), hidden_version.group(1))

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
                self.assertIn("BUILD_INFO.json", names)
                self.assertIn("ISSUE_GUIDE.md", names)
                self.assertIn("references/TASK_MAP.md", names)
                self.assertIn("references/API_MAP.md", names)
                self.assertNotIn("SectionUI.skills/SKILL.md", names)
                build_info = json.loads(archive.read("BUILD_INFO.json").decode("utf-8"))
                self.assertEqual(build_info["name"], "sectionui")

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

    def test_sync_release_version_normalizes_tags(self) -> None:
        self.assertEqual(sync_release_version.normalize_version("2.5.4"), ("2.5.4", "v2.5.4"))
        self.assertEqual(sync_release_version.normalize_version("refs/tags/v2.5.4"), ("2.5.4", "v2.5.4"))
        with self.assertRaises(ValueError):
            sync_release_version.normalize_version("2.5")


if __name__ == "__main__":
    unittest.main()
