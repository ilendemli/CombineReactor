import Foundation
import Combine

import WeakMapTable

#if !os(Linux)
#if os(iOS) || os(tvOS)
import UIKit
private typealias OSViewController = UIViewController
#elseif os(OSX)
import AppKit
private typealias OSViewController = NSViewController
#endif

private enum MapTables {
    static let reactor = WeakMapTable<AnyObject, Any>()
    static let isReactorBound = WeakMapTable<AnyObject, Bool>()
}

public protocol _ObjCStoryboardView {
    func performBinding()
}

public protocol StoryboardView: View, _ObjCStoryboardView {}

extension StoryboardView {
    public var reactor: Reactor? {
        get { MapTables.reactor.value(forKey: self) as? Reactor }
        set {
            MapTables.reactor.setValue(newValue, forKey: self)
            
            isReactorBound = false
            cancellables = .init()
            
            performBinding()
        }
    }
    
    private var isReactorBound: Bool {
        get { MapTables.isReactorBound.value(forKey: self, default: false) }
        set { MapTables.isReactorBound.setValue(newValue, forKey: self) }
    }
    
    public func performBinding() {
        guard let reactor = reactor, isReactorBound == false else {
            return
        }
        
        if shouldDeferBinding(reactor: reactor) {
            return
        }
        
        bind(reactor: reactor)
        isReactorBound = true
    }
    
    private func shouldDeferBinding(reactor: Reactor) -> Bool {
        #if !os(watchOS)
        guard let viewController = self as? OSViewController else {
            return false
        }
        
        return viewController.isViewLoaded == false
        #else
        return false
        #endif
    }
}

#if !os(watchOS)
extension OSViewController {
    @objc func _reactor_performBinding() {
        guard let viewController = self as? _ObjCStoryboardView else {
            return
        }
        
        viewController.performBinding()
    }
}
#endif
#endif
