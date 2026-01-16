# Manager & CollectionView

## SKCollectionView

`SKCollectionView` is a subclass of `UICollectionView` that comes pre-wired with `SKCManager` and logical defaults.

```swift
// Initialization
let sectionView = SKCollectionView()
view.addSubview(sectionView)

// Accessing the manager
let manager = sectionView.manager
```

It handles:
- Automatic layout updates.
- Plugin management (sticky headers, etc.).

## SKCManager

The `SKCManager` is the brain of the operation. It links your sections to the collection view.

### Primary Methods

- **`reload(_ sections: [SKCSectionProtocol])`**: Replaces all existing sections with new ones and reloads the view.
- **`insert(_ sections: [SKCSectionProtocol], at: Int)`**: Inserts sections safely.
- **`delete(_ sections: [SKCSectionProtocol])`**: Removes specific sections.

## SKCollectionViewController

A convenience `UIViewController` subclass that contains an `SKCollectionView`.

```swift
class MyPage: SKCollectionViewController {

    private lazy var section = MyCell
        .wrapperToSingleTypeSection()

    override func viewDidLoad() {
        super.viewDidLoad()
        section.config(models: [...])
        manager.reload(section)
    }
}
```
