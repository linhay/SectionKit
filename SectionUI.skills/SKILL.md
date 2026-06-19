---
name: sectionui
description: Use for SectionUI and SectionKit iOS development. Covers data-driven UICollectionView architecture in Swift, SKCManager, SKCollectionView, SKCSingleTypeSection, section builders, row mutation, reactive bindings, selection ownership, safe-size measurement, layout plugins, decorations, supplementary views, scroll/page behavior, SwiftUI hosting, nested sections, forwarding hooks, performance caches, and production list/feed/grid patterns.
metadata:
  version: "2.5.4"
---

# SectionUI Agent Guide

Use this skill to design, implement, review, or debug SectionUI screens. Keep context small: route the task first, open only the matching reference files, then answer with code that follows the framework's data-driven model.

Paths like `references/...` are relative to this skill directory (`SectionUI.skills/`). If your current working directory is the repository root, prefix paths with `SectionUI.skills/`.

## Version

Current local skill version: `v2.5.4`.

Reference snapshot: bundled `references/` describe the local SectionUI / SectionKit APIs in this repository, not live remote docs. For "latest", compare with the repository source files and the current podspec version before answering.

Install/update entrypoints:

- Release asset: download `sectionui.skill.zip` from GitHub Releases.
- Local Codex: put or symlink `SectionUI.skills/` into `$REPO_ROOT/.agents/skills/sectionui`, `$HOME/.agents/skills/sectionui`, or another official Codex scan location.
- Repository use: when this repository is the workspace, use `SectionUI.skills/` in place.

## Operating Principle

SectionUI's default model: after section / manager / view binding, business code manages data and state; cell registration, rendering, sizing, refresh, animation, exposure, selection, and scroll effects should derive from SectionUI sections, models, publishers, and section mutations.

Prefer these defaults:

- Bind through `SKCManager` or `SKCollectionViewController`, then mutate source state, section models, selection state, or cache ownership.
- Use many focused sections instead of one monolithic collection-view controller.
- Prefer `wrapperToSingleTypeSection`, result builders, supplementary views, decoration plugins, selection state, publisher bindings, and nested sections before writing custom collection plumbing.
- Keep repeated product patterns in app-level wrappers; keep framework usage generic and reusable.
- Name `UICollectionView` variables `sectionView` in examples unless matching existing project style requires another name.

## Routing

1. Classify the request.
   - Architecture, screen decomposition, source of truth, or anti-patterns: use `references/TASK_MAP.md`, then `references/data-driven-best-practices.md`.
   - Concrete API, method, protocol, or type: search `references/API_MAP.md`, then open the mapped file.
   - Broad behavior such as selection, sizing, scrolling, layout, or SwiftUI hosting: use `references/TASK_MAP.md`.
   - Unknown domain: start with `references/INDEX.md`, then refine with `rg`.

2. Choose the smallest useful reference.
   - Primary task router: `references/TASK_MAP.md`
   - API keyword router: `references/API_MAP.md`
   - Full reference index: `references/INDEX.md`

3. Open only target references.
   - For one topic, open one reference.
   - For cross-domain issues, open at most one adjacent reference unless the code proves more context is needed.
   - Prefer `*-recipes.md` files for production guidance. Use older broad files like `section.md`, `reactive.md`, or `performance.md` for API overview only.

4. Route actionable feedback.
   - If a reference is stale, an API signature is wrong, an example is broken, a packaging asset is missing, or a useful workflow is absent, use `ISSUE_GUIDE.md`.
   - Preserve structured fields such as `apiName`, `referencePath`, `sourcePath`, `sectionuiVersion`, `buildInfo`, `reproductionSteps`, and `verificationCommands`.
   - Redact private app names, local user paths, business module names, private models, screenshots with sensitive UI, logs, and payloads before filing.

## Lookup Commands

From the repository root:

- Find a concrete API route: `rg -n "SKCManager|refresh\\(|SKSelectionState" SectionUI.skills/references/API_MAP.md`
- Search all references by keyword: `rg -n "safeSize|reloadKind|pinHeader" SectionUI.skills/references`
- List topic files: `sed -n '1,220p' SectionUI.skills/references/INDEX.md`
- Prepare feedback: `sed -n '1,220p' SectionUI.skills/ISSUE_GUIDE.md`

From inside `SectionUI.skills/`, omit the `SectionUI.skills/` prefix.

## Task Map Summary

| User intent | Read first | Adjacent reference |
| --- | --- | --- |
| Data-driven architecture, source of truth, screen structure | `references/data-driven-best-practices.md` | `references/production-usage.md` |
| Section assembly, optional states, render builders | `references/composition-styling-recipes.md` | `references/render-builder-recipes.md` |
| Manager binding, reload/insert/remove, section identity | `references/manager-transaction-recipes.md` | `references/container-lifecycle-recipes.md` |
| Row refresh, append, insert, delete, `reloadKind` | `references/row-mutation-recipes.md` | `references/reactive-binding-recipes.md` |
| Publishers, `@SKPublished`, subscriptions, feedback loops | `references/reactive-binding-recipes.md` | `references/data-driven-best-practices.md` |
| Cell creation, wrappers, UIKit/SwiftUI containers | `references/view-cell-container-recipes.md` | `references/runtime-view-wrapper-recipes.md` |
| Dynamic size, Auto Layout fitting, stale cached size | `references/safe-size-measurement-recipes.md` | `references/adaptive-sizing-recipes.md` |
| Size cache, exposure counts, display tracking | `references/cache-exposure-recipes.md` | `references/rendering-performance-recipes.md` |
| Layout plugins, decoration, pinning, alignment | `references/layout-plugin-execution-recipes.md` | `references/layout-decoration-recipes.md` |
| Selection state, single/multi-select, reload-safe selection | `references/selection-ownership-recipes.md` | `references/interaction-state-recipes.md` |
| Cell actions, exposure, context menu, prefetch, reorder | `references/interaction-state-recipes.md` | `references/delegate-interaction-recipes.md` |
| Scroll observation, pending scroll, page/zoom | `references/navigation-scroll-recipes.md` | `references/page-zoom-recipes.md` |
| Nested horizontal sections or section-in-cell | `references/nested-section-cell-recipes.md` | `references/container-lifecycle-recipes.md` |
| Custom heterogeneous/raw section | `references/custom-section-patterns.md` | `references/raw-section-wrapper-recipes.md` |
| Debug helpers, cache stores, environment utilities | `references/diagnostics-utility-recipes.md` | `references/advanced-production-tips.md` |

## Code Defaults

Use these patterns unless an existing codebase has a stronger convention:

- Cell: conform to `SKLoadViewProtocol` and `SKConfigurableView`.
- Common section: `MyCell.wrapperToSingleTypeSection()` plus `config(models:)`.
- Manager: call `manager.reload(sections)` for section replacement and section-local APIs for row mutations.
- Reactive data: bind source state with `@SKPublished`, `SKPublishedValue`, or section subscriptions.
- Selection: store selection in `SKSelectionState`, `SKSelectionWrapper`, or `SKSelectionSequence`, not visible cells.
- Sizing: prefer `safeSize`, `cellSafeSize`, adaptive sizing, and high-performance cache where applicable.
- Closures: use `[weak self]` when capturing view controllers or long-lived owners.

## Boundaries

- Do not invent API signatures. Confirm concrete methods in references or source files.
- Do not answer from downstream project paths, product names, business modules, page names, or scan indexes.
- Do not recommend direct visible-cell mutation as the normal update path.
- Do not force custom `UICollectionViewDataSource` / `UICollectionViewDelegate` plumbing when SectionUI wrappers, forwarding hooks, or plugins cover the behavior.
- If a reference and source disagree, trust source for signature and mention the reference may be stale.

## Feedback Workflow

Use `ISSUE_GUIDE.md` when the user reports a requirement, bug, missing recipe, confusing behavior, stale docs, broken example, or packaging/install issue that should become a repository issue.

Feedback defaults:

- Reproduce locally when practical with `rg`, unit tests, package build, SwiftPM tests, or Xcode/simulator evidence.
- Prefer scenario-specific GitHub issue forms under `.github/ISSUE_TEMPLATE/`.
- Keep reproducibility-critical public facts: API names, versions, sanitized stack traces, minimal code, and command output.
- Remove private app source, product names, patient/user data, analytics keys, internal URLs, screenshots with sensitive UI, and full production logs.
- If using `gh`, create issues with `gh issue create --repo linhay/SectionKit --template <form>`.

## Maintenance

Use script-backed workflows for distribution and validation:

- Package skill: `python3 SectionUI.skills/scripts/package_skill.py --output sectionui.skill.zip --json`
- Sync release version: `python3 SectionUI.skills/scripts/sync_release_version.py --version 2.5.4`
- Validate metadata: `python3 -m unittest discover -s SectionUI.skills/tests`

<!-- version: 2.5.4 -->
