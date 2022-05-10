//
//  File.swift
//
//
//  Created by linhey on 2022/5/10.
//

import Foundation
import SectionKit

struct SelectableCollection<Element: SelectableProtocol>: SelectableCollectionProtocol {
    let selectables: [Element]
}
