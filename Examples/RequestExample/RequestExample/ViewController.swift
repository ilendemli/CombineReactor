// 11.05.2020

import UIKit
import Combine
import CombineReactor

class ViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    let buttonActionPassthrough = PassthroughSubject<ViewReactor.Action, Never>()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .black
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    
        return activityIndicatorView
    }()
    
    let reloadButton: UIButton = {
        let goforwardImage = UIImage(systemName: "goforward")
        
        let button = UIButton()
        button.tintColor = .black
        button.setImage(goforwardImage, for: [])
        
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        
        return stackView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(reloadButton)
        
        view.addSubview(stackView)
        view.addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        reloadButton.addTarget(self, action: #selector(reloadButtonAction), for: .touchUpInside)
    }
    
    @objc private func reloadButtonAction() {
        buttonActionPassthrough.send(.reload)
    }
}

extension ViewController: View {
    func bind(reactor: ViewReactor) {
        buttonActionPassthrough
            .eraseToAnyPublisher()
            .sink(receiveValue: reactor.action.send)
            .store(in: &cancellables)
    
        reactor.state
            .map { $0.isLoading }
            .receive(on: RunLoop.main)
            .bind(to: activityIndicatorView.r.isAnimating)
            .store(in: &cancellables)
        
        reactor.state
            .map { $0.isLoading }
            .map(!)
            .receive(on: RunLoop.main)
            .bind(to: reloadButton.r.isEnabled)
            .store(in: &cancellables)
        
        reactor.state
            .compactMap { $0.image }
            .receive(on: RunLoop.main)
            .bind(to: imageView.r.image)
            .store(in: &cancellables)
        
        reactor.state
            .compactMap { $0.error }
            .receive(on: RunLoop.main)
            .bind(to: r.error)
            .store(in: &cancellables)
    }
}

extension UIActivityIndicatorView: ReactiveCompatible {}

extension Reactive where Base: UIActivityIndicatorView {
   var isAnimating: Binder<Bool> {
        Binder(base) { (activityIndicatorView, isAnimating) in
            isAnimating ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        }
    }
}

extension UIButton: ReactiveCompatible {}

extension Reactive where Base: UIButton {
   var isEnabled: Binder<Bool> {
        Binder(base) { (button, isEnabled) in
            button.isEnabled = isEnabled
        }
    }
}

extension UIImageView: ReactiveCompatible {}

extension Reactive where Base: UIImageView {
   var image: Binder<UIImage?> {
        Binder(base) { (imageView, image) in
            imageView.image = image
        }
    }
}

extension UIViewController: ReactiveCompatible {}

extension Reactive where Base: UIViewController {
    var error: Binder<Swift.Error> {
         Binder(base) { (viewController, error) in
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(okAction)
            
            viewController.present(alertController, animated: true)
         }
     }
}
