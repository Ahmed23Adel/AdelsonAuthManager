//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

@available(macOS 10.15, *)
class TraditionalLogIn: AdelsonAuthOperation{
    var error: (any Error)?
    private let config: AdelsonAuthConfig
    private let username: String
    private let password: String
    private let networkService: AdelsonNetworkService
    private(set) var extraUserInfo: [String : String] = [:]
    
    private(set) var genericAuthRequester: GenericAuthRequester<ResponseBodyModel>
    
    
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
            url: config.traditionalLoginConfig.url)
        
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
    
    func getResult() -> ResponseBodyModel? {
        genericAuthRequester.getResult()
    }
}
