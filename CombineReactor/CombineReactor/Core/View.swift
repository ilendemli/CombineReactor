import Foundation
import Combine

import WeakMapTable

private enum MapTables {
    static let reactor = WeakMapTable<AnyObject, Any>()
}

public protocol View: class {
    associatedtype Reactor
    
    var cancellables: Set<AnyCancellable> { get set }
    
    var reactor: Reactor? { get set }
    
    func bind(reactor: Reactor)
}

extension View {
    public var reactor: Reactor? {
        get { MapTables.reactor.value(forKey: self) as? Reactor }
        set {
            MapTables.reactor.setValue(newValue, forKey: self)
            
            cancellables = .init()
            
            if let reactor = newValue {
                bind(reactor: reactor)
            }
        }
    }
}
