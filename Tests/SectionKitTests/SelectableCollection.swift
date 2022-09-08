//
//  File.swift
//
//
//  Created by linhey on 2022/5/10.
//

import Foundation
import SectionUI

struct SelectableCollection<Element: SKSelectionProtocol>: SKSelectionSequenceProtocol {
    let selectables: [Element]
}
