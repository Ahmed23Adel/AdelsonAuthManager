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
class TraditionslSignUpOperation<T: Codable & Sendable>: AdelsonAuthOperation{
        
    var error: (any Error)?
    private let config: AdelsonAuthConfig
    private let username: String
    private let password: String
    private let networkService: AdelsonNetworkService
    private(set) var extraUserInfo: [String : String] = [:]
    
    private(set) var genericAuthRequester: GenericAuthRequester<T>
    
    
    init(username: String, password: String,
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
            url: config.traditionalSignUpConfig.url)
        
    }
        
    func execute() async -> Bool {
        return await genericAuthRequester.execute()
    }

    func getUserName() -> String {
        username
    }
    
    func getPassword() -> String {
        password
    }
    
    func getExtraUserInfo(key: String) -> String {
        extraUserInfo[key, default: ""]
    }
    
    func getResult() -> T? {
        genericAuthRequester.getResult()
    }

}
