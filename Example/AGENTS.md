# PROJECT KNOWLEDGE BASE: Example

**Generated:** 2026-01-19
**Scope:** Usage patterns & Best practices from demonstrations.

## OVERVIEW
The `Example/` directory serves as the living documentation for SectionKit. It demonstrates how to decompose complex UIs into isolated, reusable units using the protocol-oriented architecture of `SectionKit` and `SectionUI`.

## COMMON PATTERNS
- **Section Initialization**: Prefer `Cell.wrapperToSingleTypeSection(models)` for concise instantiation.
- **Fluent Configuration**: Use chaining for section setup:
  ```swift
  section
    .setSectionStyle { $0.minimumLineSpacing = 10 }
    .cellSafeSize(.fraction(0.5), transforms: .height(asRatioOfWidth: 1))
    .onCellAction(.selected) { context in ... }
  ```
- **Wrapper Pattern**: Bridge any `UIView` to a cell using `SKCWrapperCell<CustomView>`. The view only needs to conform to `SKConfigurableView`.
- **Global Orchestration**: Use `SKCManager` to manage multiple sections; use `manager.reload(sections)` for full state updates.

## BEST PRACTICES
### Reactive Binding
- **Model-Driven**: Use `@SKPublished` in your model classes to broadcast state changes.
- **Cell Binding**: Inside `config(_:)`, bind to model publishers and store in `cancellables`.
- **Cleanup**: Always call `cancellables.removeAll()` at the start of `config(_:)` to prevent duplicate bindings during cell reuse.

### Diffing & Data Loading
- **Incremental Updates**: Use `section.append(models)` for pagination instead of reloading the entire manager.
- **Header/Footer**: Dynamically update decorators via `section.setHeader(View.self, model: model)` followed by `section.reload()`.
- **Memory Safety**: ALWAYS use `[weak self]` in `.onCellAction` and reactive `.bind` closures. Sections are often held by the Manager/VC, and Cells are reused; strong captures will cause leaks.

### Performance
- **Sizing**: Implement `preferredSize` in `SKLoadViewProtocol` for efficient layout calculations. Use `static` methods to avoid instantiation overhead.
- **State Management**: Keep business logic in the Section or ViewModel; keep the Cell focused strictly on rendering the provided Model.
