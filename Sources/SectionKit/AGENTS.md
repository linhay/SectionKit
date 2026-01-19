# SectionKit Internal Knowledge Base

**Generated:** 2026-01-19
**Focus:** Core Architecture, SKCManager, Section Protocol Hierarchy

## OVERVIEW (Architecture)
SectionKit is a protocol-oriented framework that decomposes `UICollectionView` complexity into independent, reusable "Sections". It follows a **Mediator Pattern**: `SKCManager` acts as the central mediator (handling all `UICollectionView` delegate/datasource calls), while individual Sections manage their own data logic and view configuration. This separation allows for heterogeneous lists where each section can have entirely different layouts and data types.

## STRUCTURE
- **CollectionBase**: Orchestrator (`SKCManager`) and the binding mechanism (`SKCSectionInjection`).
- **CollectionBaseProtocol**: The protocol hierarchy (`SKCSectionProtocol`, `SKCAnySectionProtocol`).
- **CollectionSingleTypeSection**: The primary concrete implementation (`SKCSingleTypeSection`).
- **Common**: Primitive wrappers (`SKBinding`, `SKUIAction`) and thread-safety tools (`SKActor`).
- **HighPerformance**: Performance utilities like `SKKVCache` and `SKHighPerformanceStore`.

## KEY COMPONENTS

### SKCManager
The single source of truth for the `UICollectionView`.
- **Event Forwarding**: Uses `Forwarder` classes to multiplex delegate calls to appropriate sections based on the section index.
- **Section Binding**: When a section is added, it is "injected" with an `SKCSectionInjection` instance, which provides the section with its index and access to the `UICollectionView`.
- **State Management**: Maintains the `sections` array and handles batch updates (`insert`, `delete`, `reload`).

### SKCSectionProtocol Hierarchy
- **SKCBaseSectionProtocol**: Typealias for Action + DataSource + Delegate protocols.
- **SKCAnySectionProtocol**: Provides type-erasure and `objectIdentifier` for section identity.
- **SKCSectionProtocol**: The full interface required by `SKCManager`, adding `FlowLayout` support.
- **SKCRawSectionProtocol**: Low-level access to raw `UICollectionView` methods.

### SKCSingleTypeSection<Cell>
The workhorse for 90% of use cases.
- **Generic Design**: Bound to a specific `UICollectionViewCell` and its `Model`.
- **Fluent API**: Provides a declarative way to handle cell actions (`onCellAction`), selection (`onSelected`), and styling (`applyStyle`).
- **Automatic Registration**: Handles `register(_:)` calls during the binding phase.

## DATA FLOW

1. **Initialization**: `SKCManager` is initialized with a `UICollectionView`. It installs itself as the delegate/dataSource via internal forwarders.
2. **Binding**: Sections are added to `SKCManager`. Each section receives an `SKCSectionInjection` and calls `config(sectionView:)`.
3. **Interaction**: `UICollectionView` -> `SKCManager` -> `Forwarder` -> `Section`. The Manager translates the global `IndexPath` to a section-relative `row` index.
4. **Update**: Data change in Section -> `SKCSectionInjection.reload()` -> `SKCManager.reload(section)` -> `UICollectionView.reloadSections()`.
5. **Action**: User taps Cell -> `Section.item(selected:)` -> `sendAction(.selected)` -> Triggers blocks registered via fluent API or `publishers.cellActionPulisher`.
