import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func `catch`<P>(_ handler: @escaping (Self.Failure) -> P) -> AnyPublisher<P, Never> where Self.Output == P {
        `catch` { (error) in
            Just(handler(error))
        }
        .eraseToAnyPublisher()
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func sink(receiveError: @escaping ((Self.Failure) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: { (completion) in
            guard case .failure(let error) = completion else {
                return
            }
            
            receiveError(error)
            
        }, receiveValue: { (output) in
            receiveValue(output)
        })
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func sink() -> AnyCancellable {
        sink(receiveError: { (error) in
            #if DEBUG
            Swift.print(error.localizedDescription)
            #endif
            
        }, receiveValue: { (_) in })
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Self.Failure == Never {
    public func send(to subject: PassthroughSubject<Output, Never>) -> AnyCancellable {
        sink { (value) in
            subject.send(value)
        }
    }
}
