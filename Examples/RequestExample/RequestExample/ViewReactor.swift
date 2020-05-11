// 11.05.2020

import Combine
import CombineReactor

class ViewReactor: Reactor {
    enum Action {
        case reload
    }
    
    enum Mutation {
        case setIsLoading(Bool)
        
        case setImage(UIImage?)
        case setError(Swift.Error?)
    }
    
    struct State {
        var isLoading = false
        
        var image: UIImage?
        var error: Swift.Error?
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        switch action {
        case .reload:
            let request = API().getRandomImageURL()
                .flatMap { (url) in
                    API().getImageData(from: url)
                }
                .map { (data) -> Mutation in
                    let image = UIImage(data: data)
                    return .setImage(image)
                }
                .catch { (error) -> Mutation in
                    .setError(error)
                }
                .eraseToAnyPublisher()
            
            return Empty()
                .append(.setIsLoading(true))
                .append(request)
                .append(.setIsLoading(false))
                .eraseToAnyPublisher()
        }
    }
    
    func transform(action: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never> {
        action.prepend(.reload)
            .eraseToAnyPublisher()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        
        switch mutation {
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setImage(let image):
            newState.image = image
            
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
}
