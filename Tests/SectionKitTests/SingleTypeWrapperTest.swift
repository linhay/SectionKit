//
//  File.swift
//  
//
//  Created by linhey on 2022/5/10.
//

import Foundation
import XCTest
import Combine
import SectionKit

final class SingleTypeWrapperTest: XCTestCase {
   
    struct ValidModel: Equatable {
        let isValid: Bool
    }
    
    func testUniqueSelectableWrapper() {
        let selectedIndex = [0, 2, 3]
        let models = SelectableCollection<SelectableBox<Int>>(selectables: (0...(selectedIndex.max() ?? 0)).map({ index in
                .init(index, selectable: .init(isSelected: false, canSelect: selectedIndex.contains(index)))
        }))
        
        let wrapper = SectionGenericCell<SelectableBox<Int>>.singleTypeWrapper { builder in
            builder.model(models.selectables)
        }.selectableWrapper()
        
        models.selectables.enumerated().forEach { (offset, model) in
            let lastSelectedItem  = models.firstSelectedElement()
            let lastSelectedIndex = models.firstSelectedIndex()
            wrapper.wrappedSection.item(selected: offset)
            if model.canSelect {
                assert(models.firstSelectedIndex() == offset)
                assert(models.firstSelectedElement()?.value == model.value)
            } else {
                assert(models.firstSelectedIndex() == lastSelectedIndex)
                assert(models.firstSelectedElement()?.value == lastSelectedItem?.value)
            }
        }
        
        assert(models.selectedElements.map(\.value) == [selectedIndex.last!])
        
        wrapper.wrappedSection.item(selected: -1)
        assert(models.firstSelectedIndex() == selectedIndex.last)
        assert(models.firstSelectedElement()?.value == selectedIndex.last)
    }
    
    func testSelectableWrapper() {
        let selectedIndex = [0, 2, 3]
        let models = SelectableCollection<SelectableBox<Int>>(selectables: (0...(selectedIndex.max() ?? 0)).map({ index in
                .init(index, selectable: .init(isSelected: false, canSelect: selectedIndex.contains(index)))
        }))
        
        let wrapper = SectionGenericCell<SelectableBox<Int>>.singleTypeWrapper { builder in
            builder.model(models.selectables)
        }.selectableWrapper(isUnique: false, needInvert: false)
        
        models.selectables.enumerated().forEach { (offset, model) in
            wrapper.wrappedSection.item(selected: offset)
        }
        
        assert(models.selectedElements.map(\.value) == selectedIndex)
        wrapper.wrappedSection.item(selected: -1)
        assert(models.firstSelectedIndex() == selectedIndex.first)
        assert(models.firstSelectedElement()?.value == selectedIndex.first)
    }

    func testInvertSelectableWrapper() {
        let selectedIndex = [0, 2, 3]
        let models = SelectableCollection<SelectableBox<Int>>(selectables: (0...(selectedIndex.max() ?? 0)).map({ index in
                .init(index, selectable: .init(isSelected: false, canSelect: selectedIndex.contains(index)))
        }))
        
        let wrapper = SectionGenericCell<SelectableBox<Int>>.singleTypeWrapper { builder in
            builder.model(models.selectables)
        }.selectableWrapper(isUnique: false, needInvert: true)
        
        models.selectables.enumerated().forEach { (offset, model) in
            wrapper.wrappedSection.item(selected: offset)
        }
        
        assert(models.selectedElements.map(\.value) == selectedIndex)
        wrapper.wrappedSection.item(selected: -1)
        assert(models.firstSelectedIndex() == selectedIndex.first)
        assert(models.firstSelectedElement()?.value == selectedIndex.first)
        
        
        models.selectables.enumerated().forEach { (offset, model) in
            wrapper.wrappedSection.item(selected: offset)
        }
        
        assert(models.selectedElements.map(\.value) == [])
        assert(models.firstSelectedIndex() == nil)
        assert(models.firstSelectedElement()?.value == nil)
    }

    
}

