import Foundation
import UIKit

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "http://10.10.6.83:8080"
}

// MARK: - API Endpoints
enum APIEndpoint {
    case getToken(deviceToken: String)
    
    var path: String {
        switch self {
        case .getToken:
            return "/api/v1/users/get-token"
        }
    }
    
    var url: URL? {
        switch self {
        case .getToken(let deviceToken):
            var components = URLComponents(string: APIConfig.baseURL + path)
            components?.queryItems = [URLQueryItem(name: "deviceToken", value: deviceToken)]
            return components?.url
        }
    }
}

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Token API
    func getToken(completion: @escaping (Result<TokenResponse, NetworkError>) -> Void) {
        guard let deviceToken = getDeviceToken() else {
            completion(.failure(.noDeviceToken))
            return
        }
        
        guard let url = APIEndpoint.getToken(deviceToken: deviceToken).url else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 API Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 응답 로깅
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(.noData))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Received Data: \(jsonString)")
            }

            if data.isEmpty {
                print("❌ Received empty data")
                completion(.failure(.emptyData))
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                print("✅ Successfully decoded token response")
                completion(.success(tokenResponse))
            } catch {
                print("❌ Decoding Error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    private func getDeviceToken() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
}

// MARK: - Models
struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case emptyData
    case noDeviceToken
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .emptyData:
            return "Empty data received"
        case .noDeviceToken:
            return "Device token not found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
