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
    
    
    
    func execute() async throws -> Bool {
        do {
            print("jjjj1", config.traditionalSignUpConfig.signUpUrl)
            let _ = try await networkService.request(
                url: config.traditionalSignUpConfig.signUpUrl,
                method: .post,
                parameters: getUserCodableObject(),
                responseType: T.self)
            print("jjjj1", config.traditionalSignUpConfig.signUpUrl)
            return true
        } catch {
            try handleNetworkError(error as! SignUpError)
            return true
        }
    }
    
    private func getUserCodableObject() -> SignUpBody{
        SignUpBody(username: username, password: password)
    }
    
    private func handleNetworkError(_ error: SignUpError) throws {
        switch error {
        case .networkError(_, let statusCode):
            if statusCode != nil && statusCode == 400 {
                throw TraditionslSignUpOperationErrors.UserNameAlreadyExists
            }
        case .invalidURL,
                .noResponse,
                .decodingError:
            throw error
            
        }
    }
    func getUserName() -> String {
        username
    }
    
    func getPassword() -> String {
        password
    }
    
}
