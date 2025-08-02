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
    case startFeedback(fileId: String)
    case getFeedbackDetail(feedbackId: String)
    
    var path: String {
        switch self {
        case .getToken:
            return "/api/v1/users/get-token"
        case .uploadPortfolio:
            return "/api/v1/files/portfolio"
        case .startFeedback:
            return "/api/v1/feedback/start"
        case .getFeedbackDetail:
            return "/api/v1/feedback"
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
        case .startFeedback(let fileId):
            var components = URLComponents(string: APIConfig.baseURL + path)
            components?.queryItems = [URLQueryItem(name: "fileId", value: fileId)]
            return components?.url
        case .getFeedbackDetail(let feedbackId):
            var components = URLComponents(string: APIConfig.baseURL + path)
            components?.queryItems = [URLQueryItem(name: "feedbackId", value: feedbackId)]
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
        request.timeoutInterval = 10.0
        
        print("📤 Sending token API request...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                print("📋 Response Headers: \(httpResponse.allHeaderFields)")
            }
            
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
                let apiResponse = try JSONDecoder().decode(TokenAPIResponse.self, from: data)
                print("✅ Successfully decoded API response")
                print("📊 Status: \(apiResponse.status), Code: \(apiResponse.code)")
                print("💬 Message: \(apiResponse.message)")
                
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
    
    // MARK: - Upload Portfolio API
    func uploadPortfolio(fileURL: URL, accessToken: String, completion: @escaping (Result<PortfolioUploadResponse, NetworkError>) -> Void) {
        guard let url = APIEndpoint.uploadPortfolio.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 Upload API Request URL: \(url.absoluteString)")
        print("📁 File URL: \(fileURL.absoluteString)")
        
        guard let fileData = try? Data(contentsOf: fileURL) else {
            print("❌ Failed to read file data")
            completion(.failure(.fileReadError))
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60.0
        
        var body = Data()
        
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
    
    // MARK: - Start Feedback API
    func startFeedback(fileId: String, accessToken: String, completion: @escaping (Result<FeedbackStartResponse, NetworkError>) -> Void) {
        guard let url = APIEndpoint.startFeedback(fileId: fileId).url else {
            print("❌ Invalid URL for feedback start API")
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 Feedback Start API Request URL: \(url.absoluteString)")
        print("🆔 File ID: \(fileId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30.0
        
        print("📤 Sending feedback start API request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Feedback Start HTTP Status Code: \(httpResponse.statusCode)")
                print("📋 Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let error = error {
                print("❌ Feedback Start Network Error: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                print("❌ No feedback start response data received")
                completion(.failure(.noData))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Feedback Start Response Data: \(jsonString)")
            }
            
            if data.isEmpty {
                print("❌ Received empty feedback start data")
                completion(.failure(.emptyData))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(FeedbackStartAPIResponse.self, from: data)
                print("✅ Successfully decoded feedback start response")
                print("📊 Feedback Status: \(apiResponse.status), Code: \(apiResponse.code)")
                print("💬 Feedback Message: \(apiResponse.message)")
                
                guard apiResponse.status == "OK" else {
                    print("❌ Feedback Start API Error - Status: \(apiResponse.status), Message: \(apiResponse.message)")
                    completion(.failure(.apiError(apiResponse.code, apiResponse.message)))
                    return
                }
                
                guard let feedbackResult = apiResponse.result else {
                    print("❌ No feedback result data in API response")
                    completion(.failure(.noResultData))
                    return
                }
                
                let feedbackResponse = FeedbackStartResponse(
                    feedbackId: feedbackResult.feedbackId
                )
                
                print("🎯 Feedback ID: \(feedbackResult.feedbackId)")
                
                completion(.success(feedbackResponse))
                
            } catch {
                print("❌ Feedback Start Decoding Error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON for debugging: \(jsonString)")
                }
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Get Feedback Detail API (새로 추가)
    func getFeedbackDetail(feedbackId: String, accessToken: String, completion: @escaping (Result<FeedbackDetailResponse, NetworkError>) -> Void) {
        guard let url = APIEndpoint.getFeedbackDetail(feedbackId: feedbackId).url else {
            print("❌ Invalid URL for feedback detail API")
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 Feedback Detail API Request URL: \(url.absoluteString)")
        print("🆔 Feedback ID: \(feedbackId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15.0
        
        print("📤 Sending feedback detail API request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Feedback Detail HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                print("❌ Feedback Detail Network Error: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                print("❌ No feedback detail response data received")
                completion(.failure(.noData))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Feedback Detail Response Data: \(jsonString)")
            }
            
            if data.isEmpty {
                print("❌ Received empty feedback detail data")
                completion(.failure(.emptyData))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(FeedbackDetailAPIResponse.self, from: data)
                print("✅ Successfully decoded feedback detail response")
                print("📊 Feedback Detail Status: \(apiResponse.status), Code: \(apiResponse.code)")
                print("💬 Feedback Detail Message: \(apiResponse.message)")
                
                guard apiResponse.status == "OK" else {
                    print("❌ Feedback Detail API Error - Status: \(apiResponse.status), Message: \(apiResponse.message)")
                    completion(.failure(.apiError(apiResponse.code, apiResponse.message)))
                    return
                }
                
                guard let feedbackResult = apiResponse.result else {
                    print("❌ No feedback detail result data in API response")
                    completion(.failure(.noResultData))
                    return
                }
                
                let feedbackResponse = FeedbackDetailResponse(
                    feedback: feedbackResult.feedback
                )
                
                print("🎯 Overall Status: \(feedbackResult.feedback.overallStatus)")
                print("🎯 Project Status: \(feedbackResult.feedback.projectStatus)")
                
                completion(.success(feedbackResponse))
                
            } catch {
                print("❌ Feedback Detail Decoding Error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON for debugging: \(jsonString)")
                }
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    private func getDeviceToken() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
}

// MARK: - Models

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

// 피드백 시작 API 응답 구조
struct FeedbackStartAPIResponse: Codable {
    let status: String
    let code: String
    let message: String
    let result: FeedbackStartResult?
}

struct FeedbackStartResult: Codable {
    let feedbackId: String
}

struct FeedbackStartResponse: Codable {
    let feedbackId: String
}

// 피드백 상세 조회 API 응답 구조 (새로 추가)
struct FeedbackDetailAPIResponse: Codable {
    let status: String
    let code: String
    let message: String
    let result: FeedbackDetailResult?
}

struct FeedbackDetailResult: Codable {
    let feedback: FeedbackDetail
}

struct FeedbackDetail: Codable {
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let id: String
    let userId: String
    let fileId: String
    let title: String
    let overallStatus: String
    let projectStatus: String
}

struct FeedbackDetailResponse: Codable {
    let feedback: FeedbackDetail
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
