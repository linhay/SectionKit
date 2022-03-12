// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

public protocol ConfigurableView: UIView, ConfigurableModelProtocol {
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize
}

public extension ConfigurableView {


    static func preferredSize(model: Model?) -> CGSize {
        Self.preferredSize(limit: .zero, model: model)
    }

    static func preferredHeight(width: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: model).height
    }

    static func preferredWidth(height: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: model).width
    }

    func preferredSize(model: Model?) -> CGSize {
        Self.preferredSize(limit: .zero, model: model)
    }

    func preferredHeight(width: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: model).height
    }

    func preferredWidth(height: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: model).width
    }

}

public extension ConfigurableView where Model == Void {

    static func preferredSize() -> CGSize {
        Self.preferredSize(limit: .zero, model: nil)
    }

    static func preferredHeight(width: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: nil).height
    }

    static func preferredWidth(height: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: nil).width
    }

    func preferredSize() -> CGSize {
        Self.preferredSize(limit: .zero, model: nil)
    }

    static func preferredSize(limit size: CGSize) -> CGSize {
        Self.preferredSize(limit: size, model: nil)
    }

    func preferredHeight(width: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: nil).height
    }

    func preferredWidth(height: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: nil).width
    }

}
#endif
