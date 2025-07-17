//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public class DecoratorSaveAuthToken: AdelsonAuthOperationDecorator{
    public var operation: any AdelsonAuthOperation<ResponseBodyModel>
    public var error: (any Error)?
    public var extraUserInfo: [String : String] = [:]
    private let keychainManager = KeychainManager.shared
    private let config: AdelsonAuthConfig
    
    public init(operation: any AdelsonAuthOperation<ResponseBodyModel>, config: AdelsonAuthConfig) {
        self.operation = operation
        self.config = config
    }
    
    public func _execute() async -> Bool {
        if await operation.execute(){
            let accessToken: String = operation.getResult()!.access_token
            let refreshToken: String = operation.getResult()!.refresh_token
            let _ = await keychainManager.save(accessToken.data(using:.utf8)!, account: config.keychainConfig.accessTokenAccount)
            let _ = await keychainManager.save(refreshToken.data(using:.utf8)!, account: config.keychainConfig.refreshTokenAccount)
            return true
        } else{
            return false
        }
        
    }
        
    public func getResult() -> ResponseBodyModel? {
        operation.getResult()
    }
    
    
}
