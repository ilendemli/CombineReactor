import Foundation
import Combine

import WeakMapTable

private enum MapTables {
    static let cancellables = WeakMapTable<AnyObject, Set<AnyCancellable>>()
    static let currentState = WeakMapTable<AnyObject, Any>()
    static let action = WeakMapTable<AnyObject, AnyObject>()
    static let state = WeakMapTable<AnyObject, AnyObject>()
}

public protocol Reactor: class {
    associatedtype Action
    associatedtype Mutation = Action
    associatedtype State
    
    var action: PassthroughSubject<Action, Never> { get }
    
    var initialState: State { get }
    var currentState: State { get }
    
    var state: AnyPublisher<State, Never> { get }
    
    func transform(action: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never>
    func mutate(action: Action) -> AnyPublisher<Mutation, Never>
    func transform(mutation: AnyPublisher<Mutation, Never>) -> AnyPublisher<Mutation, Never>
    func reduce(state: State, mutation: Mutation) -> State
    func transform(state: AnyPublisher<State, Never>) -> AnyPublisher<State, Never>
}

// MARK: - Default Implementations
extension Reactor {
    private var _action: PassthroughSubject<Action, Never> {
        MapTables.action.forceCastedValue(forKey: self, default: .init())
    }
    
    public var action: PassthroughSubject<Action, Never> {
        _ = _state
        
        return _action
    }
    
    public internal(set) var currentState: State {
        get { MapTables.currentState.forceCastedValue(forKey: self, default: initialState) }
        set { MapTables.currentState.setValue(newValue, forKey: self) }
    }
    
    private var _state: AnyPublisher<State, Never> {
        MapTables.state.forceCastedValue(forKey: self, default: createStateStream())
    }
    
    public var state: AnyPublisher<State, Never> {
        _state
    }
    
    fileprivate var cancellables: Set<AnyCancellable> {
        get { MapTables.cancellables.value(forKey: self, default: .init()) }
        set { MapTables.cancellables.setValue(newValue, forKey: self) }
    }

    public func createStateStream() -> AnyPublisher<State, Never> {
        let replaySubject = ReplaySubject<State, Never>(maxBufferSize: 1)
        
        let action = _action
            .receive(on: RunLoop.current)
            .eraseToAnyPublisher()
        
        let mutation = transform(action: action)
            .flatMap { [weak controller = self] action -> AnyPublisher<Mutation, Never> in
                guard let controller = controller else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return controller.mutate(action: action)
            }
            .eraseToAnyPublisher()
        
        let state = transform(mutation: mutation)
            .scan(initialState) { [weak controller = self] (state, mutation) -> State in
                guard let controller = controller else {
                    return state
                }
                
                return controller.reduce(state: state, mutation: mutation)
            }
            .prepend(initialState)
            .eraseToAnyPublisher()
        
        let transformedState = transform(state: state)
            .handleEvents(receiveOutput: { [weak controller = self] (state) in
                guard let controller = controller else {
                    return
                }
                
                controller.currentState = state
            })
            .multicast(subject: replaySubject)
        
        transformedState.connect().store(in: &cancellables)
        
        return transformedState.eraseToAnyPublisher()
    }
    
    public func transform(action: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never> {
        action
    }
    
    public func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    public func transform(mutation: AnyPublisher<Mutation, Never>) -> AnyPublisher<Mutation, Never> {
        mutation
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        state
    }
    
    public func transform(state: AnyPublisher<State, Never>) -> AnyPublisher<State, Never> {
        state
    }
}

extension Reactor where Action == Mutation {
    public func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        Just(action).eraseToAnyPublisher()
    }
}
