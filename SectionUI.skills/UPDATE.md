# Update SectionUI Skill

Current version: `v2.5.7`.

## From GitHub Releases

1. Download `sectionui.skill.zip` from the matching GitHub Release.
2. Replace the existing skill directory, for example `.agents/skills/sectionui` or `$HOME/.agents/skills/sectionui`.
3. Verify `VERSION.md`, `SKILL.md`, and packaged `BUILD_INFO.json` all point at the expected version/tag.
4. Do not merge old bundled `references/` into the new skill. Replace the directory so removed references stay removed.

## From a Local Checkout

Use a symlink when developing against this repository:

```bash
mkdir -p "$HOME/.agents/skills"
ln -s /path/to/SectionKit/SectionUI.skills "$HOME/.agents/skills/sectionui"
```

## Release Maintainers

Run the release workflow instead of hand-editing packaged files. It syncs `SKILL.md`, `VERSION.md`, `UPDATE.md`, podspec versions, creates the release tag, packages `sectionui.skill.zip`, and publishes CocoaPods.
