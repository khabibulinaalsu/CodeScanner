import Foundation
import Combine

class NetworkService {
    struct Response: Codable {
        let product: ProductInfo?
    }
    
    private let baseURL = "https://world.openfoodfacts.org/api/v0/product/"
    
    func fetchProductInfo(barcode: String) -> AnyPublisher<ProductInfo?, Error> {
        let urlString = "\(baseURL)\(barcode).json"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Response.self, decoder: JSONDecoder())
            .map(\.product)
            .eraseToAnyPublisher()
    }
}

