//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 09/07/2025.
//

import Foundation
import Alamofire
import AdelsonValidator



@available(macOS 10.15, *)
struct TraditionslSignUpOperation<T: Codable & Sendable>: AdelsonAuthOperation{
    var error: (any Error)?
    private let config: AdelsonAuthConfig
    private let username: String
    private let password: String
    private let networkService: AdelsonNetworkService
    
    
    
    init(username: String, password: String,
         config: AdelsonAuthConfig,
         networkService: AdelsonNetworkService = AlamoFireNetworkService()){
        self.config = config
        self.username = username
        self.password = password
        self.networkService = networkService
    }
    
    
    
    mutating func execute() async -> Bool {
        do {
            let _ = try await networkService.request(
                url: config.traditionalSignUpConfig.signUpUrl,
                method: .post,
                parameters: getUserCodableObject(),
                responseType: T.self)
            return true
        } catch {
            self.error = handleNetworkError(error as! SignUpError)
            print("self.error", self.error)
            return false
        }
    }
    
    private func getUserCodableObject() -> SignUpBody{
        SignUpBody(username: username, password: password)
    }
    
    private func handleNetworkError(_ error: SignUpError) -> (any Error)? {
        switch error {
        case .networkError(_, let statusCode):
            if statusCode != nil && statusCode == 400 {
                return TraditionslSignUpOperationErrors.UserNameAlreadyExists
            }
        case .invalidURL,
                .noResponse,
                .decodingError:
            return error
            
        }
       return nil
    }
    func getUserName() -> String {
        username
    }
    
    func getPassword() -> String {
        password
    }
    
}
