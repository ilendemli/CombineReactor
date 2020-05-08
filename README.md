# CombineReactor

[![Version](https://img.shields.io/cocoapods/v/CombineReactor.svg?style=flat)](https://cocoapods.org/pods/CombineReactor)
[![License](https://img.shields.io/cocoapods/l/CombineReactor.svg?style=flat)](https://cocoapods.org/pods/CombineReactor)
[![Platform](https://img.shields.io/cocoapods/p/CombineReactor.svg?style=flat)](https://cocoapods.org/pods/CombineReactor)

CombineReactor is a [ReactorKit](https://www.github.com/ReactorKit/ReactorKit) inspired wrapper for Swift Combine.
Includes a "Binder" to add bindable capabilities to default implementation by conforming to `ReactiveCompatible` and extending `Reactive`. See the example below.

Contributions and feedback are welcome and appreciated.

## Example Usage

#### Reactor
```swift
import Foundation
import Combine

import CombineReactor

class CounterReactor: Reactor {
    enum Action {
        case decrease
        case increase
    }

    enum Mutation {
        case decreaseValue
        case increaseValue
        case setIsLoading(Bool)
    }

    struct State {
        var value: Int = 0
        var isLoading: Bool = false
    }

    let initialState = State()

    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        switch action {
        case .decrease:
            let step: AnyPublisher<Mutation, Never> = Empty()
                .append(.decreaseValue)
                .delay(for: .seconds(1), scheduler: RunLoop.current)
                .eraseToAnyPublisher()
            
            return Empty()
                .append(.setIsLoading(true))
                .append(step)
                .append(.setIsLoading(false))
                .eraseToAnyPublisher()
            
        case .increase:
            let step: AnyPublisher<Mutation, Never> = Empty()
                .append(.increaseValue)
                .delay(for: .seconds(1), scheduler: RunLoop.current)
                .eraseToAnyPublisher()
        
            return Empty()
                .append(.setIsLoading(true))
                .append(step)
                .append(.setIsLoading(false))
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
            
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
}
```

#### ReactiveCompatible & Reactive
```swift
extension UILabel: ReactiveCompatible {}

extension Reactive where Base: UILabel {
   var text: Binder<String?> {
        Binder(base) { (label, text) in
            label.text = text
        }
    }
}

extension UIActivityIndicatorView: ReactiveCompatible {}

extension Reactive where Base: UIActivityIndicatorView {
   var isAnimating: Binder<Bool> {
        Binder(base) { (activityIndicator, isAnimating) in
            isAnimating ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
}
```

#### ViewController & View
```swift
extension ViewController: View {
    func bind(reactor: CounterReactor) {
        buttonActionPassthrough
            .eraseToAnyPublisher()
            .sink(receiveValue: reactor.action.send)
            .store(in: &cancellables)
            
        reactor.state
            .map { $0.value }
            .map { String(format: "%i", $0) }
            .bind(to: valueLabel.r.text )
            .store(in: &cancellables)

        reactor.state
            .map { $0.isLoading }
            .removeDuplicates()
            .bind(to: activityIndicator.r.isAnimating)
            .store(in: &cancellables)
    }
}
```

## Installation
### Cocoapods
```ruby
pod 'CombineReactor', git: 'https://github.com/ilendemli/CombineReactor.git'
```

### SPM
```swift
.package(url: "https://github.com/ilendemli/CombineReactor.git", .upToNextMajor(from: "0.1"))
```

### Other Managers
Feel free to create a pull request

## Requirements
* Swift 5.1
* iOS 13
* watchOS 6
* tvOS 13
* macOS 10.15

## License
CombineReactor is available under the MIT license. See the [LICENSE](https://github.com/ilendemli/CombineReactor/blob/master/LICENSE) file for more info.
