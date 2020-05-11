// 11.05.2020

import UIKit
import Combine
import CombineReactor

class ViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    let buttonActionPassthrough = PassthroughSubject<ViewReactor.Action, Never>()
    
    let decreaseButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: [])
        button.setTitle("-", for: [])
        
        return button
    }()
    
    let valueLabel = UILabel()
    
    let increaseButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: [])
        button.setTitle("+", for: [])
        
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        stackView.addArrangedSubview(decreaseButton)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(increaseButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        decreaseButton.addTarget(self, action: #selector(decreaseButtonAction), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseButtonAction), for: .touchUpInside)
    }
    
    @objc private func decreaseButtonAction() {
        buttonActionPassthrough.send(.decrease)
    }
    
    @objc private func increaseButtonAction() {
        buttonActionPassthrough.send(.increase)
    }
}

extension ViewController: View {
    func bind(reactor: ViewReactor) {
        buttonActionPassthrough
            .eraseToAnyPublisher()
            .sink(receiveValue: reactor.action.send)
            .store(in: &cancellables)
        
        reactor.state
            .map { $0.value }
            .map { String(format: "%i", $0) }
            .bind(to: valueLabel.r.text)
            .store(in: &cancellables)
    }
}

extension UILabel: ReactiveCompatible {}

extension Reactive where Base: UILabel {
   var text: Binder<String?> {
        Binder(base) { (label, text) in
            label.text = text
        }
    }
}
