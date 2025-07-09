//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 07/07/2025.
//
import Foundation

actor KeychainManager {
    // MARK: shared object configuration
    nonisolated(unsafe) static var _shared: KeychainManager?
    static let lock = NSLock()
    
    let config: AdelsonAuthConfig
    
    static var shared: KeychainManager {
        lock.lock()
        defer { lock.unlock() }
        
        guard let instance = _shared else {
            fatalError("KeychainManager must be configured with configure() before accessing shared instance")
        }
        return instance
    }
    
    private init(config: sending AdelsonAuthConfig) {
        self.config = config
    }
    
    static func configure(with config: sending AdelsonAuthConfig) {
        lock.lock()
        defer { lock.unlock() }
        
        guard _shared == nil else {
            print("KeychainManager is already configured, this will be ignored")
            return
        }
        _shared = KeychainManager(config: config)
    }
    
    // MARK: CRUD properties
    private var service: String {
        "com.\(config.appName).AdelsonAuthManager"
    }
    
    // MARK: CRUD operations
    func save(_ data: Data, account: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary
        
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        return status == errSecSuccess
    }
    
    func update(_ data: Data, account: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        let attributesToUpdate = [
            kSecValueData: data
        ] as CFDictionary
        
        let status = SecItemUpdate(query, attributesToUpdate)
        return status == errSecSuccess
    }
    
    func read(account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        return status == errSecSuccess ? result as? Data : nil
    }
    
    func delete(account: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    
}
