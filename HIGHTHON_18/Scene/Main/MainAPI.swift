import Foundation
import UIKit

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "http://10.10.6.83:8080"
}

// MARK: - API Endpoints
enum APIEndpoint {
    case getToken(deviceToken: String)
    case uploadPortfolio
    
    var path: String {
        switch self {
        case .getToken:
            return "/api/v1/users/get-token"
        case .uploadPortfolio:
            return "/api/v1/files/portfolio"
        }
    }
    
    var url: URL? {
        switch self {
        case .getToken(let deviceToken):
            var components = URLComponents(string: APIConfig.baseURL + path)
            components?.queryItems = [URLQueryItem(name: "deviceToken", value: deviceToken)]
            return components?.url
        case .uploadPortfolio:
            return URL(string: APIConfig.baseURL + path)
        }
    }
}

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Token API (수정된 부분)
    func getToken(completion: @escaping (Result<TokenResponse, NetworkError>) -> Void) {
        print("🚀 Starting token API call...")
        
        guard let deviceToken = getDeviceToken() else {
            print("❌ No device token available")
            completion(.failure(.noDeviceToken))
            return
        }
        
        print("📱 Device Token: \(deviceToken)")
        
        guard let url = APIEndpoint.getToken(deviceToken: deviceToken).url else {
            print("❌ Invalid URL for token API")
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 API Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0  // 타임아웃 단축
        
        print("📤 Sending token API request...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 응답 로깅
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                print("📋 Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            // 에러 체크
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .timedOut:
                        completion(.failure(.networkError(NSError(domain: "NetworkTimeout", code: -1001, userInfo: [NSLocalizedDescriptionKey: "서버가 응답하지 않습니다. 네트워크 연결을 확인해주세요."]))))
                    case .cannotConnectToHost:
                        completion(.failure(.networkError(NSError(domain: "ConnectionFailed", code: -1004, userInfo: [NSLocalizedDescriptionKey: "서버에 연결할 수 없습니다. 서버 주소를 확인해주세요."]))))
                    default:
                        completion(.failure(.networkError(error)))
                    }
                } else {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            // 데이터 체크
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(.noData))
                return
            }
            
            // 받은 데이터 로깅
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Received Data: \(jsonString)")
            }
            
            // 빈 데이터 체크
            if data.isEmpty {
                print("❌ Received empty data")
                completion(.failure(.emptyData))
                return
            }
            
            // JSON 파싱
            do {
                // API 명세에 맞는 응답 구조로 파싱
                let apiResponse = try JSONDecoder().decode(TokenAPIResponse.self, from: data)
                print("✅ Successfully decoded API response")
                print("📊 Status: \(apiResponse.status), Code: \(apiResponse.code)")
                print("💬 Message: \(apiResponse.message)")
                
                // API 응답 상태 확인
                guard apiResponse.status == "OK" else {
                    print("❌ API Error - Status: \(apiResponse.status), Message: \(apiResponse.message)")
                    completion(.failure(.apiError(apiResponse.code, apiResponse.message)))
                    return
                }
                
                guard let tokenResult = apiResponse.result else {
                    print("❌ No result data in API response")
                    completion(.failure(.noResultData))
                    return
                }
                
                // TokenResponse 형식으로 변환
                let tokenResponse = TokenResponse(
                    accessToken: tokenResult.accessToken,
                    expirationTime: tokenResult.expirationTime
                )
                
                print("🔑 Access Token: \(tokenResult.accessToken.prefix(20))...")
                print("⏰ Expiration Time: \(tokenResult.expirationTime) seconds")
                
                completion(.success(tokenResponse))
                
            } catch {
                print("❌ Decoding Error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON for debugging: \(jsonString)")
                }
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
        print("⏳ Task started, waiting for response...")
    }
    
    func uploadPortfolio(fileURL: URL, accessToken: String, completion: @escaping (Result<PortfolioUploadResponse, NetworkError>) -> Void) {
        guard let url = APIEndpoint.uploadPortfolio.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 Upload API Request URL: \(url.absoluteString)")
        print("📁 File URL: \(fileURL.absoluteString)")
        
        // 파일 데이터 읽기
        guard let fileData = try? Data(contentsOf: fileURL) else {
            print("❌ Failed to read file data")
            completion(.failure(.fileReadError))
            return
        }
        
        // Multipart form data 생성
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60.0  // 파일 업로드는 더 긴 타임아웃
        
        var body = Data()
        
        // 파일 데이터 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📤 Uploading file: \(fileURL.lastPathComponent)")
        print("📏 File size: \(fileData.count) bytes")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Upload HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                print("❌ Upload Network Error: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                print("❌ No upload response data received")
                completion(.failure(.noData))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Upload Response Data: \(jsonString)")
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(UploadAPIResponse.self, from: data)
                print("✅ Successfully decoded upload response")
                print("📊 Upload Status: \(apiResponse.status), Code: \(apiResponse.code)")
                print("💬 Upload Message: \(apiResponse.message)")
                
                guard apiResponse.status == "OK" else {
                    print("❌ Upload API Error - Status: \(apiResponse.status), Message: \(apiResponse.message)")
                    completion(.failure(.apiError(apiResponse.code, apiResponse.message)))
                    return
                }
                
                guard let uploadResult = apiResponse.result else {
                    print("❌ No upload result data in API response")
                    completion(.failure(.noResultData))
                    return
                }
                
                let uploadResponse = PortfolioUploadResponse(
                    id: uploadResult.id,
                    logicalName: uploadResult.logicalName,
                    url: uploadResult.url
                )
                
                print("🎯 Upload ID: \(uploadResult.id)")
                print("📄 Logical Name: \(uploadResult.logicalName)")
                print("🔗 URL: \(uploadResult.url)")
                
                completion(.success(uploadResponse))
            } catch {
                print("❌ Upload Decoding Error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    private func getDeviceToken() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
}

// MARK: - Models (API 명세에 맞게 수정)

// 토큰 API 응답 구조
struct TokenAPIResponse: Codable {
    let status: String
    let code: String
    let message: String
    let result: TokenResult?
}

struct TokenResult: Codable {
    let accessToken: String
    let expirationTime: String
}

// 사용하기 쉬운 TokenResponse 구조
struct TokenResponse: Codable {
    let accessToken: String
    let expirationTime: String
}

// 업로드 API 응답 구조
struct UploadAPIResponse: Codable {
    let status: String
    let code: String
    let message: String
    let result: PortfolioUploadResult?
}

struct PortfolioUploadResult: Codable {
    let id: String
    let logicalName: String
    let url: String
}

struct PortfolioUploadResponse: Codable {
    let id: String
    let logicalName: String
    let url: String
}

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case emptyData
    case noDeviceToken
    case noResultData
    case fileReadError
    case apiError(String, String) // code, message
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다"
        case .noData:
            return "서버로부터 데이터를 받지 못했습니다"
        case .emptyData:
            return "빈 데이터를 받았습니다"
        case .noDeviceToken:
            return "디바이스 토큰을 찾을 수 없습니다"
        case .noResultData:
            return "API 응답에 결과 데이터가 없습니다"
        case .fileReadError:
            return "파일을 읽을 수 없습니다"
        case .apiError(let code, let message):
            return "API 오류 [\(code)]: \(message)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "데이터 파싱 오류: \(error.localizedDescription)"
        }
    }
}
