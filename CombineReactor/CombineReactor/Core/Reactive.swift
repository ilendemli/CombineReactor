import Foundation
import Combine

public struct Reactive<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}
