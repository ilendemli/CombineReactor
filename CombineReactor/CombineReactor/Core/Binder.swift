import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never {
    public func bind(to target: Binder<Output>) -> AnyCancellable {
        sink { (value) in
            target.on(value)
        }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Error {
    public func bind(to target: Binder<Output>) -> AnyCancellable {
        sink(receiveError: { (error) in
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            Swift.print(error.localizedDescription)
            #endif
            
        }, receiveValue: { (value) in
            target.on(value)
        })
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct Binder<Value> {
    private let _binding: (Value) -> Void
    
    public init<Target: AnyObject>(_ target: Target, binding: @escaping (Target, Value) -> Void) {
        _binding = { [weak target] (value) in
            if let target = target {
                binding(target, value)
            }
        }
    }
    
    public func on(_ value: Value) {
        _binding(value)
    }
}
