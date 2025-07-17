//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation


@available(macOS 10.15, *)
public class TraditionslRefreshToken: AdelsonAuthOperation{
    public var error: (any Error)?
    private let networkService: AdelsonNetworkService
    public var extraUserInfo: [String : String] = [:]
    private(set) var result: ResponseBodyModel?
    private var config: AdelsonAuthConfig
    
    
    public init(username: String, password: String,
         config: AdelsonAuthConfig,
         extraUserInfo: [String : String] = [:],
         networkService: AdelsonNetworkService,
    ){
        self.networkService = networkService
        self.config = config
        
    }
        
    public func execute() async -> Bool {
        do {
            let requestResult = try await networkService.request(
                url: self.config.refreshTokenConfig.url,
                method: .post,
                parameters: getUserCodableObject(),
                responseType: ResponseBodyModel.self)
            result = requestResult
            return true
        } catch {
            self.error = handleNetworkError(error as! SignUpError)
            return false
        }
    }
    
    private func getUserCodableObject() async -> [String: String]{
        let body = ["refresh_token": await AuthTokenStore.shared.getRefreshToken()!]
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
        ""
    }
    
    public func getPassword() -> String {
        ""
    }
    
    public func getExtraUserInfo(key: String) -> String {
        extraUserInfo[key, default: ""]
    }
    
    public func getResult() -> ResponseBodyModel? {
         result
    }
}
