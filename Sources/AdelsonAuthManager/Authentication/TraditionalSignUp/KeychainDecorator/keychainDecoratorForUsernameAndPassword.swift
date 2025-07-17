//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 16/07/2025.
//

import Foundation

class keychainDecoratorForUsernameAndPassword<T: Codable & Sendable>: AdelsonAuthOperationDecorator{
    var operation: any AdelsonAuthOperation<T>
    var error: (any Error)?
    var keychainManager: KeychainManager
    var config: AdelsonAuthConfig
    var extraUserInfo: [String : String] = [:]
    
    init(operation: any AdelsonAuthOperation<T>, keychainManager: KeychainManager, config: AdelsonAuthConfig) {
        self.operation = operation
        self.keychainManager = keychainManager
        self.config = config
    }
    // it should be the last in the chain,
    // so i call all the chain first, and if it succeeds, i call my self (keychain) to save the result in the end
    func execute() async -> Bool {
        if await operation.execute() {
            return await _execute()
        } else{
            return false
        }
    }
    func _execute() async -> Bool {
        let _ = await keychainManager.save(getUserName().data(using: .utf8) ?? Data(), account: config.keychainConfig.usernameAccount)
        let _ = await keychainManager.save(getPassword().data(using: .utf8) ?? Data(), account: config.keychainConfig.passwordAccount)
        return true
    }
    
    func getUserName() -> String {
        return operation.getUserName()
    }
    
    func getPassword() -> String {
        operation.getPassword()
    }
    
    func getExtraUserInfo(key: String) -> String {
        operation.getExtraUserInfo(key: key)
    }
    
    func getResult() -> T? {
        operation.getResult()
    }
}
