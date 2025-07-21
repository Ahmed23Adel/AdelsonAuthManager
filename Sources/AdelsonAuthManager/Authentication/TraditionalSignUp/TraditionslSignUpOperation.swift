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
public class TraditionslSignUpOperation<T: Codable & Sendable>: AdelsonAuthOperation{
        
    public var error: (any Error)?
    private let config: AdelsonAuthConfig
    private let username: String
    private let password: String
    private let networkService: AdelsonNetworkService
    public var extraUserInfo: [String : String] = [:]
    
    private(set) var genericAuthRequester: GenericAuthRequester<T>
    
    
    public init(username: String, password: String,
         config: AdelsonAuthConfig,
         extraUserInfo: [String : String] = [:],
         networkService: AdelsonNetworkService = AlamoFireNetworkService()){
        self.config = config
        self.username = username
        self.password = password
        self.networkService = networkService
        self.extraUserInfo = extraUserInfo
        self.genericAuthRequester = GenericAuthRequester(
            username: username,
            password: password,
            config: config,
            networkService: AlamoFireNetworkService(),
            url: config.traditionalSignUpConfig.url)
        
    }
        
    public func execute() async -> Bool {
        return await genericAuthRequester.execute()
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
        genericAuthRequester.getResult()
    }

}
