//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 10/07/2025.
//

import Foundation
import Alamofire

@available(macOS 10.15, *)
final class AlamoFireNetworkService: AdelsonNetworkService{
    
    func request<T: Decodable & Sendable, P: Encodable & Sendable>(
            url: String,
            method: Alamofire.HTTPMethod,
            parameters: P,
            responseType: T.Type
        ) async throws -> T {
            
            try await withCheckedThrowingContinuation { continuation in
                print("url", url)
                AF.request(
                    url,
                    method: method,
                    parameters: parameters,
                    encoder: JSONParameterEncoder.default
                )
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        continuation.resume(returning: value)
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            print("❌ Error:", error.localizedDescription, "Status:", statusCode)
                            continuation.resume(throwing: SignUpError.networkError(error, statusCode: statusCode))
                        } else if error.isSessionTaskError {
                            print("🔌 Possibly unreachable server or invalid URL")
                            continuation.resume(throwing: SignUpError.invalidURL)
                        } else if error.isResponseSerializationError {
                            continuation.resume(throwing: SignUpError.decodingError(error))
                        } else {
                            continuation.resume(throwing: SignUpError.networkError(error, statusCode: nil))
                        }
                    }
                }
            }
        }
}
