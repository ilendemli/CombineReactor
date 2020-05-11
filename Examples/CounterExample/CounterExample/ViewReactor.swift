// 11.05.2020

import Foundation
import Combine
import CombineReactor

class ViewReactor: Reactor {
    enum Action {
        case decrease
        case increase
    }
    
    enum Mutation {
        case decreaseValue
        case increaseValue
    }
    
    struct State {
        var value: Int = 0
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        switch action {
        case .decrease:
            return Empty()
                .append(.decreaseValue)
                .eraseToAnyPublisher()
            
        case .increase:
            return Empty()
                .append(.increaseValue)
                .eraseToAnyPublisher()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .decreaseValue:
            newState.value -= 1
            
        case .increaseValue:
            newState.value += 1
        }
        
        return newState
    }
}
