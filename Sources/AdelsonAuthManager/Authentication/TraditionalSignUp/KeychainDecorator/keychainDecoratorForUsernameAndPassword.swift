//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 16/07/2025.
//

import Foundation

public class keychainDecoratorForUsernameAndPassword<T: Codable & Sendable>: AdelsonAuthOperationDecorator{
    public var operation: any AdelsonAuthOperation<T>
    public var error: (any Error)?
    var keychainManager: KeychainManager
    var config: AdelsonAuthConfig
    public var extraUserInfo: [String : String] = [:]
    
    public init(operation: any AdelsonAuthOperation<T>, keychainManager: KeychainManager, config: AdelsonAuthConfig) {
        self.operation = operation
        self.keychainManager = keychainManager
        self.config = config
    }
    // it should be the last in the chain,
    // so i call all the chain first, and if it succeeds, i call my self (keychain) to save the result in the end
    public func execute() async -> Bool {
        if await operation.execute() {
            return await _execute()
        } else{
            return false
        }
    }
    public func _execute() async -> Bool {
        let _ = await keychainManager.save(getUserName().data(using: .utf8) ?? Data(), account: config.keychainConfig.usernameAccount)
        let _ = await keychainManager.save(getPassword().data(using: .utf8) ?? Data(), account: config.keychainConfig.passwordAccount)
        return true
    }
    
    public func getUserName() -> String {
        return operation.getUserName()
    }
    
    public func getPassword() -> String {
        operation.getPassword()
    }
    
    public func getExtraUserInfo(key: String) -> String {
        operation.getExtraUserInfo(key: key)
    }
    
    public func getResult() -> T? {
        operation.getResult()
    }
}
