---
name: sectionui-preview
description: Generate SwiftUI Previews for SectionUI components.
---

# sectionkit-preview

Use this skill to quickly setup SwiftUI previews for your cells or sections.

## Usage Scenarios

### 1. Previewing Sections
Uses `SKPreview.sections` to display one or more sections.

```swift
import SwiftUI
import SectionUI

#Preview {
    SKPreview.sections {
        <#YourCell#>.wrapperToSingleTypeSection(<#models#>)
    }
}
```

### 3. Previewing Multiple Cells
Since `SKPreview` takes sections, you can preview distinct cell states by wrapping them.

```swift
#Preview {
    SKPreview.sections {
        MyCell.wrapperToSingleTypeSection {
            Model(state: .normal)
            Model(state: .selected)
            Model(state: .disabled)
        }
    }
}
```


### 3. Previewing Multiple Cells
Since `SKPreview` takes sections, you can preview distinct cell states by wrapping them.

```swift
#Preview {
    SKPreview.sections {
        MyCell.wrapperToSingleTypeSection {
            Model(state: .normal)
            Model(state: .selected)
            Model(state: .disabled)
        }
    }
}
```


### 2. Previewing a View Controller
If you want to preview a full `SKCollectionViewController`.

```swift
#Preview {
    UIViewController.sk.toSwiftUI {
        let vc = <#MyViewController#>()
        // Mock data or setup if needed
        return vc
    }
}
```

## Tips
- Previews are great for fast iteration on cell layouts and spacing.
- You can combine multiple sections in a single preview block.
