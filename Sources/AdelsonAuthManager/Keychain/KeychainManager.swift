//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 07/07/2025.
//
import Foundation

public actor KeychainManager {
    // MARK: shared object configuration
    nonisolated(unsafe) static var _shared: KeychainManager?
    static let lock = NSLock()
    
    let config: AdelsonAuthConfig
    
    public static var shared: KeychainManager {
        lock.lock()
        defer { lock.unlock() }
        
        guard let instance = _shared else {
            fatalError("KeychainManager must be configured with configure() before accessing shared instance")
        }
        return instance
    }
    
    private init(config: sending AdelsonAuthConfig) {
        print("configure2")
        self.config = config
    }
    
    public static func configure(with config: sending AdelsonAuthConfig) {
        print("configure1")
        lock.lock()
        defer { lock.unlock() }
        
        guard _shared == nil else {
            print("KeychainManager is already configured, this will be ignored")
            return
        }
        _shared = KeychainManager(config: config)
    }
    
    // MARK: CRUD properties
    public  var service: String {
        "com.\(config.appName).AdelsonAuthManager"
    }
    
    // MARK: CRUD operations
    public func save(_ data: Data, account: String) -> Bool {
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
    
    public func update(_ data: Data, account: String) -> Bool {
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
    
    public func read(account: String) -> Data? {
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
    
    public func delete(account: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    
}
