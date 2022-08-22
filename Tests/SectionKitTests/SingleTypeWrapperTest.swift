////
////  File.swift
////
////
////  Created by linhey on 2022/5/10.
////
//
//import Combine
//import Foundation
//import SectionKit
//import XCTest
//
//final class SingleTypeWrapperTest: XCTestCase {
//    let collectionView = SKCollectionView()
//
//    struct ReloadModel: Equatable {
//        static func == (lhs: SingleTypeWrapperTest.ReloadModel, rhs: SingleTypeWrapperTest.ReloadModel) -> Bool {
//            lhs.value == rhs.value
//        }
//
//        let value: Int
//        var isReload: Bool
//
//        init(value: Int, isReload: Bool) {
//            self.value = value
//            self.isReload = isReload
//        }
//    }
//
//    func testDiffWrapper() {
//        let data = [1, 2, 3, 4, 5, 6].map { ReloadModel(value: $0, isReload: false) }
//        let data2 = [1, 2, 2, 5, 6, 3, 4, 5, 6].map { ReloadModel(value: $0, isReload: true) }
//
//        let wrapper = SectionGenericCell<ReloadModel>.singleTypeWrapper(data).differenceWrapper
//        collectionView.manager.update(wrapper)
//
//        wrapper.config(models: data2, id: \.value)
//        assert(wrapper.models?.map(\.value) == data.applying(data2.difference(from: data))?.map(\.value))
//        assert(wrapper.models?.map(\.isReload) == data.applying(data2.difference(from: data))?.map(\.isReload))
//    }
//
//    func testUniqueSelectableWrapper() {
//        let selectedIndex = [0, 2, 3]
//        let models = SelectableCollection<SKSelectableBox<Int>>(selectables: (0 ... (selectedIndex.max() ?? 0)).map { index in
//            .init(index, selectable: .init(isSelected: false, canSelect: selectedIndex.contains(index)))
//        })
//
//        let wrapper = SectionGenericCell<SKSelectableBox<Int>>.singleTypeWrapper { builder in
//            builder.model(models.selectables)
//        }.selectableWrapper()
//
//        models.selectables.enumerated().forEach { offset, model in
//            let lastSelectedItem = models.firstSelectedElement()
//            let lastSelectedIndex = models.firstSelectedIndex()
//            wrapper.wrappedSection.item(selected: offset)
//            if model.canSelect {
//                assert(models.firstSelectedIndex() == offset)
//                assert(models.firstSelectedElement()?.value == model.value)
//            } else {
//                assert(models.firstSelectedIndex() == lastSelectedIndex)
//                assert(models.firstSelectedElement()?.value == lastSelectedItem?.value)
//            }
//        }
//
//        assert(models.selectedElements.map(\.value) == [selectedIndex.last!])
//
//        wrapper.wrappedSection.item(selected: -1)
//        assert(models.firstSelectedIndex() == selectedIndex.last)
//        assert(models.firstSelectedElement()?.value == selectedIndex.last)
//    }
//
//    func testSelectableWrapper() {
//        let selectedIndex = [0, 2, 3]
//        let models = SelectableCollection<SKSelectableBox<Int>>(selectables: (0 ... (selectedIndex.max() ?? 0)).map { index in
//            .init(index, selectable: .init(isSelected: false, canSelect: selectedIndex.contains(index)))
//        })
//
//        let wrapper = SectionGenericCell<SKSelectableBox<Int>>.singleTypeWrapper { builder in
//            builder.model(models.selectables)
//        }.selectableWrapper(isUnique: false, needInvert: false)
//
//        models.selectables.enumerated().forEach { offset, _ in
//            wrapper.wrappedSection.item(selected: offset)
//        }
//
//        assert(models.selectedElements.map(\.value) == selectedIndex)
//        wrapper.wrappedSection.item(selected: -1)
//        assert(models.firstSelectedIndex() == selectedIndex.first)
//        assert(models.firstSelectedElement()?.value == selectedIndex.first)
//    }
//
//    func testInvertSelectableWrapper() {
//        let selectedIndex = [0, 2, 3]
//        let models = SelectableCollection<SKSelectableBox<Int>>(selectables: (0 ... (selectedIndex.max() ?? 0)).map { index in
//            .init(index, selectable: .init(isSelected: false, canSelect: selectedIndex.contains(index)))
//        })
//
//        let wrapper = SectionGenericCell<SKSelectableBox<Int>>.singleTypeWrapper { builder in
//            builder.model(models.selectables)
//        }.selectableWrapper(isUnique: false, needInvert: true)
//
//        models.selectables.enumerated().forEach { offset, _ in
//            wrapper.wrappedSection.item(selected: offset)
//        }
//
//        assert(models.selectedElements.map(\.value) == selectedIndex)
//        wrapper.wrappedSection.item(selected: -1)
//        assert(models.firstSelectedIndex() == selectedIndex.first)
//        assert(models.firstSelectedElement()?.value == selectedIndex.first)
//
//        models.selectables.enumerated().forEach { offset, _ in
//            wrapper.wrappedSection.item(selected: offset)
//        }
//
//        assert(models.selectedElements.map(\.value) == [])
//        assert(models.firstSelectedIndex() == nil)
//        assert(models.firstSelectedElement()?.value == nil)
//    }
//}
