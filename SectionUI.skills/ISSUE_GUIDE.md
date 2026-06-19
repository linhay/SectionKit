# Issue Guide

Use this guide when a SectionUI user reports a requirement, bug, missing capability, confusing behavior, stale API guidance, packaging problem, or documentation gap that should become a GitHub issue for this repository.

Repository: `linhay/SectionKit`

## Scenario Forms

Choose the issue form that matches the workflow under investigation:

| Scenario | Form | Direct URL |
| --- | --- | --- |
| SectionUI API/reference lookup, stale docs, wrong signature, missing routing | `sectionui-reference-api.yml` | `https://github.com/linhay/SectionKit/issues/new?template=sectionui-reference-api.yml` |
| Usage recipe, architecture guidance, production pattern, missing best practice | `sectionui-usage-recipe.yml` | `https://github.com/linhay/SectionKit/issues/new?template=sectionui-usage-recipe.yml` |
| Example/template issue, sample code compile failure, outdated snippet | `sectionui-example-template.yml` | `https://github.com/linhay/SectionKit/issues/new?template=sectionui-example-template.yml` |
| Skill packaging, release asset, install path, `BUILD_INFO.json`, versioning | `sectionui-skill-packaging.yml` | `https://github.com/linhay/SectionKit/issues/new?template=sectionui-skill-packaging.yml` |
| Framework behavior, runtime bug, layout, selection, performance, regression | `sectionui-framework-behavior.yml` | `https://github.com/linhay/SectionKit/issues/new?template=sectionui-framework-behavior.yml` |

## Workflow

1. Clarify only the minimum missing detail needed to avoid filing a wrong issue.
2. Reproduce or inspect locally when possible. Prefer focused checks:
   - `rg -n "<APIName|keyword>" Sources SectionUI.skills/references`
   - `python3 -m unittest discover -s SectionUI.skills/tests`
   - `python3 SectionUI.skills/scripts/package_skill.py --output /tmp/sectionui.skill.zip --json`
   - `swift test` when the report concerns Swift package behavior.
   - Xcode build or simulator evidence when the report concerns UIKit/runtime behavior.
3. Preserve structured fields instead of flattening them into prose:
   - `query`
   - `expectedBehavior`
   - `actualBehavior`
   - `apiName`
   - `referencePath`
   - `sourcePath`
   - `sectionuiVersion`
   - `releaseTag`
   - `buildInfo`
   - `platform`
   - `xcodeVersion`
   - `iosVersion`
   - `reproductionSteps`
   - `minimalCode`
   - `verificationCommands`
   - `artifacts`
4. Redact private data before filing:
   - Replace local usernames, absolute private repo paths, product names, business modules, patient/user data, analytics keys, internal hosts, private URLs, and screenshots with sensitive UI.
   - Keep reproducibility-critical facts such as public API names, SectionUI/SectionKit version, iOS/Xcode version, sanitized stack traces, and minimal code.
   - Do not attach full private app source, screenshots with personal data, production logs, or business payloads unless the user explicitly asked and redaction is verified.
5. Choose the scenario form from the table above.
6. Classify the issue:
   - `bug`: behavior is broken, unstable, misleading, or inconsistent with source/reference behavior.
   - `feature`: user needs a new capability, example, wrapper pattern, or skill workflow.
   - `docs`: documentation, onboarding, examples, routing, or troubleshooting are unclear or stale.
   - `question`: only if no concrete repository change is identifiable yet.
7. Create the issue with the matching direct URL, or use `gh issue create --repo linhay/SectionKit --template <form>` when the local GitHub CLI supports the selected issue form.
8. Report the issue URL back to the user with a short summary and local verification result.

## Scenario Template Fields

### SectionUI API / Reference

Form: `sectionui-reference-api.yml`

Include:

- User query and expected API/topic.
- Local reference path used, such as `SectionUI.skills/references/API_MAP.md`.
- Source path checked under `Sources/SectionUI` or `Sources/SectionKit`.
- Wrong/missing API signature, stale example, missing router keyword, or missing reference path.
- `rg` command used to verify the mismatch.

### Usage Recipe / Production Pattern

Form: `sectionui-usage-recipe.yml`

Include:

- Screen type: list, feed, grid, nested section, selection, pagination, SwiftUI hosting, or other.
- Current pattern and pain point.
- Desired recipe or best-practice rule.
- Existing references that are close but incomplete.
- Minimal sanitized code sketch when useful.

### Example / Template

Form: `sectionui-example-template.yml`

Include:

- Example/template file path under `SectionUI.skills/examples/` or `shells/xctemplate/`.
- Compile/runtime error if present.
- Expected modern SectionUI pattern.
- Whether the example should be copied into apps or only used by agents.

### Skill Packaging / Release

Form: `sectionui-skill-packaging.yml`

Include:

- Release tag or local build command.
- `BUILD_INFO.json` from the packaged `sectionui.skill.zip`.
- Expected asset name and actual asset name.
- Install path used, such as `.agents/skills/sectionui` or `$HOME/.agents/skills/sectionui`.
- Output from `python3 -m unittest discover -s SectionUI.skills/tests`.

### Framework Behavior / Runtime

Form: `sectionui-framework-behavior.yml`

Include:

- SectionUI / SectionKit version.
- iOS version, Xcode version, device/simulator.
- Minimal section/cell/manager setup.
- Expected and actual behavior.
- Whether behavior reproduces with a simple `SKCSingleTypeSection`.
- Relevant stack trace, layout output, or sanitized screenshot if needed.

Do not attach private app repositories, full view controllers, private models, raw analytics payloads, or screenshots containing sensitive user data unless sharing is explicitly approved and redaction is verified.
