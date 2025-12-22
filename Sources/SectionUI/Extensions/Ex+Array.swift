//
//  Array.swift
//  iDxyer
//
//  Created by 林翰 on 2019/9/12.
//

import Foundation

// https://github.com/linhay/Stone/blob/master/Sources/Stone/release/Stdlib/Array.swift
// MARK: - Value & pass for unit test & document
extension Array {

    /// Accesses the element at the specified position.
    ///
    /// The following example uses indexed subscripting to get an array's element
    ///
    ///     let numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    ///     numbers.value(at: 0)     // Prints 0
    ///     numbers.value(at: 9)     // Prints 9
    ///     numbers.value(at: -1)    // Prints nil
    ///     numbers.value(at: -9)    // Prints nil
    ///     numbers.value(at: -20)   // Prints nil
    ///     numbers.value(at: 20)    // Prints nil
    ///
    /// - Parameter index: The location of the element to access.
    ///       When `index` is a positive integer, it is equivalent to [`index`].
    ///       When `index` is a negative integer, it is equivalent to [`count` + `index`].
    ///       Returns `nil` when `index` exceeds the threshold.
    ///
    /// - Complexity: Reading an element from an array is O(1).
    func value(at index: Int) -> Element? {
        guard index < count, index >= 0 else { return nil }
        return self[index]
    }

    func value(at index: UInt) -> Element? {
        return value(at: Int(index))
    }
}
