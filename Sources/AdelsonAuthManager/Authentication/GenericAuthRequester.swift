//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation


@available(macOS 10.15, *)
public class GenericAuthRequester<T: Codable & Sendable>: AdelsonAuthOperation{
    public var error: (any Error)?
    private let username: String
    private let password: String
    private let networkService: AdelsonNetworkService
    public var extraUserInfo: [String : String] = [:]
    private let url: String
    private(set) var result: T?
    
    
    public init(username: String, password: String,
         config: AdelsonAuthConfig,
         extraUserInfo: [String : String] = [:],
         networkService: AdelsonNetworkService,
         url: String
    ){
        self.username = username
        self.password = password
        self.networkService = networkService
        self.extraUserInfo = extraUserInfo
        self.url = url
        
    }
        
    public func execute() async -> Bool {
        do {
            let requesResult = try await networkService.request(
                url: self.url,
                method: .post,
                parameters: getUserCodableObject(),
                responseType: T.self)
            result = requesResult
            return true
        } catch {
            self.error = handleNetworkError(error as! SignUpError)
            return false
        }
    }
    
    private func getUserCodableObject() -> [String: String]{
        var body = ["username": username,
                "password": password]
        for (key, value) in extraUserInfo {
            body[key] = value
        }
        print("1Body sent", body)
        return body
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
    public func getUserName() -> String {
        username
    }
    
    public func getPassword() -> String {
        password
    }
    
    public func getExtraUserInfo(key: String) -> String {
        extraUserInfo[key, default: ""]
    }
    
    public func getResult() -> T? {
         result
    }
}
