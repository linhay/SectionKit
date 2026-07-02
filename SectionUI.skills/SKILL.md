---
name: sectionui
description: Use for SectionUI and SectionKit iOS development. Covers data-driven UICollectionView architecture in Swift, SKCManager, SKCollectionView, SKCSingleTypeSection, section builders, row mutation, reactive bindings, selection ownership, safe-size measurement, layout plugins, decorations, supplementary views, scroll/page behavior, SwiftUI hosting, nested sections, forwarding hooks, performance caches, and production list/feed/grid patterns.
metadata:
  version: "2.5.7"
---

# SectionUI Agent Guide

Use this skill to design, implement, review, or debug SectionUI screens. Keep context small: route the task first, open only the matching reference files, then answer with code that follows the framework's data-driven and data-binding model.

Paths like `references/...` are relative to this skill directory (`SectionUI.skills/`). If your current working directory is the repository root, prefix paths with `SectionUI.skills/`.

## Version

Current local skill version: `v2.5.7`.

Reference snapshot: bundled `references/` describe the local SectionUI / SectionKit APIs in this repository, not live remote docs. For "latest", compare with the repository source files and the current podspec version before answering.

Install/update entrypoints:

- Release asset: download `sectionui.skill.zip` from GitHub Releases.
- Update guide: read `UPDATE.md`; current version is also mirrored in `VERSION.md`.
- Local Codex: put or symlink `SectionUI.skills/` into `$REPO_ROOT/.agents/skills/sectionui`, `$HOME/.agents/skills/sectionui`, or another official Codex scan location.
- Repository use: when this repository is the workspace, use `SectionUI.skills/` in place.

## Operating Principle

SectionUI's default model: after section / manager / view binding, business code manages data and state; cell registration, rendering, sizing, refresh, animation, exposure, selection, and scroll effects should derive from SectionUI sections, models, publishers, and section mutations.

Prefer these defaults:

- Bind through `SKCManager` or `SKCollectionViewController`, then mutate source state, section models, selection state, or cache ownership.
- Decide one source of truth per screen slice before writing update code: publisher-owned state uses `subscribe(models:)`; section-owned state uses `apply`, `refresh`, `append`, `insert`, `remove`, or `delete`.
- Use many focused sections instead of one monolithic collection-view controller.
- Prefer `wrapperToSingleTypeSection`, result builders, supplementary views, decoration plugins, selection state, publisher bindings, and nested sections before writing custom collection plumbing.
- Keep repeated product patterns in app-level wrappers; keep framework usage generic and reusable.
- Name `UICollectionView` variables `sectionView` in examples unless matching existing project style requires another name.

## Routing

1. Classify the request.
   - Architecture, screen decomposition, source of truth, UI update flow, binding strategy, high-frequency row state, or anti-patterns: use `references/TASK_MAP.md`, then `references/data-driven-best-practices.md`.
   - Publishers, `@SKPublished`, stable cell view models, `subscribe(models:)`, `SKBinding`, or feedback loops: use `references/reactive-binding-recipes.md`, with `references/data-driven-best-practices.md` for ownership decisions.
   - Layout plugins, plugin scope, plugin priority, attribute mutation, pinning, decorations, or invalidation: use `references/layout-plugin-execution-recipes.md`, then `references/layout-decoration-recipes.md` only for decoration/frame rules.
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
   - Prefer `*-recipes.md` files for production guidance. Use older broad files like `section.md` for API overview only.

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
| Data binding strategy, publisher-owned vs section-owned updates, high-frequency row visual state | `references/data-driven-best-practices.md` | `references/reactive-binding-recipes.md` |
| Section assembly, optional states, render builders | `references/composition-styling-recipes.md` | `references/render-builder-recipes.md` |
| Manager binding, reload/insert/remove, section identity | `references/manager-transaction-recipes.md` | `references/container-lifecycle-recipes.md` |
| Row refresh, append, insert, delete, `reloadKind` | `references/row-mutation-recipes.md` | `references/reactive-binding-recipes.md` |
| Publishers, `@SKPublished`, subscriptions, feedback loops | `references/reactive-binding-recipes.md` | `references/data-driven-best-practices.md` |
| Cell creation, wrappers, UIKit/SwiftUI containers | `references/view-cell-container-recipes.md` | `references/runtime-view-wrapper-recipes.md` |
| Dynamic size, Auto Layout fitting, stale cached size | `references/safe-size-measurement-recipes.md` | `references/adaptive-sizing-recipes.md` |
| Size cache, exposure counts, display tracking | `references/cache-exposure-recipes.md` | `references/rendering-performance-recipes.md` |
| Layout plugin system, scope, priority, invalidation, custom forwards | `references/layout-plugin-execution-recipes.md` | `references/layout-decoration-recipes.md` |
| Decoration frames, backgrounds, z-index, supplementary alignment | `references/layout-decoration-recipes.md` | `references/layout-plugin-execution-recipes.md` |
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
- Reactive data: bind source state with `@SKPublished`, `SKPublishedValue`, or section subscriptions when the publisher owns the section; use stable cell view models for high-frequency visual fields that do not affect height or structure.
- Imperative data: use section row mutation APIs directly when the section owner is already the source of truth.
- Selection: store selection in `SKSelectionState`, `SKSelectionWrapper`, or `SKSelectionSequence`, not visible cells.
- Sizing: prefer `safeSize`, `cellSafeSize`, adaptive sizing, and high-performance cache where applicable.
- Plugins: prefer section-level plugins for section-specific behavior, collection-level modes for whole-screen rules, and existing helpers before custom forwards.
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
- Validate reference compatibility: `python3 SectionUI.skills/scripts/reference_compat.py --json`
- Verify release package: `python3 SectionUI.skills/scripts/verify_skill_package.py --output sectionui.skill.zip --json`
- Validate metadata: `python3 -m unittest discover -s SectionUI.skills/tests`

<!-- version: 2.5.7 -->
