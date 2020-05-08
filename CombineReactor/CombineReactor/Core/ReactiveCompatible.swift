import Foundation
import Combine

public protocol ReactiveCompatible {
    associatedtype Base
    
    var r: Reactive<Base> { get set }
}

extension ReactiveCompatible {
    public var r: Reactive<Self> {
        get {
            Reactive(self)
        }
        // swiftlint:disable:next unused_setter_value
        set { }
    }
}
