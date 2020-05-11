// 11.05.2020

import UIKit
import Combine

enum APIError {
    case noData
    case url
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No Data"
            
        case .url:
            return "Invalid URL"
        }
    }
}

struct APIResponse: Decodable {
    let url: URL
}

struct API {
    func getRandomImageURL() -> Future<URL, Swift.Error> {
        guard let url = URL(string: "https://api.thecatapi.com/v1/images/search") else {
            return Future(failure: APIError.url)
        }

        return Future<URL, Swift.Error> { (promise) in
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    if let error = error {
                        throw error
                    }

                    guard let data = data else {
                        throw APIError.noData
                    }
                    
                    let model = try JSONDecoder().decode([APIResponse].self, from: data)
                    
                    guard let firstObject = model.first else {
                        throw APIError.noData
                    }
                    
                    promise(.success(firstObject.url))
                    
                } catch {
                    promise(.failure(error))
                }
            }.resume()
        }
    }
    
    func getImageData(from url: URL) -> Future<Data, Swift.Error> {
        Future<Data, Swift.Error> { (promise) in
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    if let error = error {
                        throw error
                    }

                    guard let data = data else {
                        throw APIError.noData
                    }
                    
                    promise(.success(data))
                    
                } catch {
                    promise(.failure(error))
                }
            }.resume()
        }
    }
}

extension Future {
    public convenience init(failure: Failure) {
        self.init { (promise) in
            promise(.failure(failure))
        }
    }
}
