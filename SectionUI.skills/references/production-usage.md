# Production Usage Patterns

This reference captures generic SectionUI rules distilled from large application surfaces. It is not an index of downstream projects. Keep it focused on reusable framework guidance, not app names, file paths, or local business concepts.

### 1. Business lists are section compositions

For real feature screens, build small named sections and compose them through `manager.reload(sections)`.

Guideline:

```swift
var sections: [SKCBaseSectionProtocol] = []
sections.append(titleSection)
sections.append(contentSection)
manager.reload(sections)
sectionView.set(pluginModes: [.decorations(decorationModes)])
```

Use this shape for feeds, search results, subscriptions, dashboards, and pages with optional modules.

When optional modules affect layout, build the final section array first, then derive decoration or plugin configuration from the resulting section instances.

### 2. Fluent section configuration is the default

For homogeneous lists, prefer the chainable section API:

```swift
let section = Cell
    .wrapperToSingleTypeSection(models)
    .setSectionStyle(\.sectionInset, inset)
    .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], spacing)
    .onCellAction(.selected) { [weak self] context in
        self?.open(context.model)
    }
```

Use subclassing only when the section owns real behavior, such as selection orchestration, diff application, reusable logging, or a domain-specific render contract.

### 3. Events live with the section

Attach navigation, analytics, exposure, and separator styling close to the section declaration.

Use:

- `onCellAction(.selected)` for taps and routing.
- `onCellAction(.willDisplay)` for first exposure when display count is not needed.
- `model(displayedAt:)` / `displayedTimes.trigger` when each model needs counted exposure.
- `setCellStyle` for row-dependent separators and visual state.

Always capture controllers weakly, or use the local `on: self` helpers when available.

### 4. Selection state belongs in models

When a list has selected cells, make the model conform to `SKSelectionProtocol` and use one of:

- `SKSelectionSequence` for ordered or single-selection lists.
- `SKSelectionIdentifiableSequence` when identity is stable and independent of row offset.
- `SKSelectionWrapper` when the raw domain model should not own selection state.

For repeated selection behavior, wrap it in a reusable section subclass or helper that owns the sequence and overrides `item(selected:)`.

### 5. Use nested horizontal sections for rows, not custom collection plumbing

For "row contains a horizontal list" UI:

- Prefer `wrapperToHorizontalSection(height:insets:style:)` for a simple child row.
- Use `SKCSectionViewCell.Model` when the child row needs multiple sections, custom sizing, or custom inner collection style.
- Keep the inner `SKCollectionView` named `sectionView` and reload it through its manager.

### 6. `@SKPublished` is used beyond collection sections

Use `@SKPublished` / `SKPublishedValue` as lightweight reactive state primitives in reducers, views, switches, loading states, and expanding cells.

Use transforms intentionally:

```swift
@SKPublished(transform: [.removeDuplicates()]) var isExpanded = false
```

Use a `SKPublishedValue<T>` model field when a cell or reusable view should observe a value directly without replacing the whole model.

### 7. Keep app-specific conveniences out of the framework

Some behavior is better implemented in the app or design-system layer:

- Diff sections that apply `CollectionDifference` through `delete` / `insert`.
- Selection-aware sections for `SKSelectionProtocol` models.
- Grid/action-sheet wrappers composed from nested sections.
- Settings rows, spacers, dividers, labels, and one-off UI building blocks.

If a proposed SectionUI API only serves app-specific convenience, keep it in the integration layer unless multiple independent products need the same primitive.

## Anti-Patterns From Production Review

- Do not create a new cell class for a simple label, spacer, divider, image, or button. Use `SKWrapperView` or an existing integration-level view.
- Do not keep selected row indexes as separate controller state when the model can conform to `SKSelectionProtocol`.
- Do not hard-code decoration section indexes before all optional sections are composed.
- Do not capture controllers strongly in `onCellAction`, supplementary callbacks, Combine sinks, or delayed layout closures.
- Do not reload the entire manager for a local list update when `SKCSingleTypeSection` can `config`, `apply`, `insert`, `delete`, or a diff section fits.
- Do not put analytics far away from the section that defines the tap/exposure surface; it becomes hard to verify row indexes and object IDs.
