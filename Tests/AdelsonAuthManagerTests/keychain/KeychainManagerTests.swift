//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 09/07/2025.
//

import Foundation
@testable import AdelsonAuthManager

import XCTest
import Foundation
@testable import AdelsonAuthManager

class KeychainManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset the singleton before each test
        KeychainManager._shared = nil
    }
    
    override func tearDown() {
        // Clean up any test data from keychain
        if let manager = KeychainManager._shared {
            Task {
                await manager.delete(account: "test_account")
                await manager.delete(account: "test_account_2")
                await manager.delete(account: "")
                await manager.delete(account: "special_chars_🔑")
            }
        }
        KeychainManager._shared = nil
        super.tearDown()
    }
    
    // MARK: - Configuration Tests
    
    func testConfigureKeychainManagerSuccessfully() async{
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        
        // Act
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        
        // Assert
        XCTAssertNotNil(manager)
        let appName = await manager.config.appName
        XCTAssertEqual(appName, "TestApp")
    }
    
    func testAccessSharedInstanceAfterConfiguration() {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        
        // Act
        let manager1 = KeychainManager.shared
        let manager2 = KeychainManager.shared
        
        // Assert
        XCTAssertTrue(manager1 === manager2, "Should return same instance")
    }
    
    func testPreventMultipleConfigurations() async{
        // Arrange
        let config1 = AdelsonAuthConfig(appName: "TestApp1", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        let config2 = AdelsonAuthConfig(appName: "TestApp2", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        
        // Act
        KeychainManager.configure(with: config1)
        KeychainManager.configure(with: config2) // This should be ignored
        
        let manager = KeychainManager.shared
        
        // Assert
        let appName = await manager.config.appName
        XCTAssertEqual(appName, "TestApp1", "Should keep first configuration")
    }
    
//    func testFailToAccessUnconfiguredSharedInstance() {
//        // Arrange & Act & Assert
//        XCTAssertThrowsError(try {
//            _ = KeychainManager.shared
//        }(), "Should throw fatal error when accessing unconfigured instance")
//    }
    
    // MARK: - Save Operation Tests
    
    func testSaveDataToKeychainSuccessfully() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "test_data".data(using: .utf8)!
        let account = "test_account"
        
        // Act
        let result = await manager.save(testData, account: account)
        
        // Assert
        XCTAssertTrue(result, "Save operation should succeed")
    }
    
    func testSaveDataOverwritesExistingItem() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let originalData = "original_data".data(using: .utf8)!
        let newData = "new_data".data(using: .utf8)!
        let account = "test_account"
        
        // Act
        let firstSave = await manager.save(originalData, account: account)
        let secondSave = await manager.save(newData, account: account)
        let retrievedData = await manager.read(account: account)
        
        // Assert
        XCTAssertTrue(firstSave, "First save should succeed")
        XCTAssertTrue(secondSave, "Second save should succeed")
        XCTAssertEqual(retrievedData, newData, "Should retrieve the new data")
    }
    
    func testSaveEmptyData() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let emptyData = Data()
        let account = "test_account"
        
        // Act
        let result = await manager.save(emptyData, account: account)
        
        // Assert
        XCTAssertTrue(result, "Should be able to save empty data")
    }
    
    func testSaveWithEmptyAccountString() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "test_data".data(using: .utf8)!
        let emptyAccount = ""
        
        // Act
        let result = await manager.save(testData, account: emptyAccount)
        
        // Assert
        XCTAssertTrue(result, "Should be able to save with empty account string")
    }
    
    func testSaveWithSpecialCharactersInAccount() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "test_data".data(using: .utf8)!
        let specialAccount = "special_chars_🔑@#$%"
        
        // Act
        let result = await manager.save(testData, account: specialAccount)
        
        // Assert
        XCTAssertTrue(result, "Should handle special characters in account")
    }
    
    // MARK: - Update Operation Tests
    
    func testUpdateExistingKeychainItem() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let originalData = "original_data".data(using: .utf8)!
        let updatedData = "updated_data".data(using: .utf8)!
        let account = "test_account"
        
        // Act
        let saveResult = await manager.save(originalData, account: account)
        let updateResult = await manager.update(updatedData, account: account)
        let retrievedData = await manager.read(account: account)
        
        // Assert
        XCTAssertTrue(saveResult, "Save should succeed")
        XCTAssertTrue(updateResult, "Update should succeed")
        XCTAssertEqual(retrievedData, updatedData, "Should retrieve updated data")
    }
    
    func testUpdateNonExistentKeychainItem() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "test_data".data(using: .utf8)!
        let nonExistentAccount = "non_existent_account"
        
        // Act
        let result = await manager.update(testData, account: nonExistentAccount)
        
        // Assert
        XCTAssertFalse(result, "Update should fail for non-existent item")
    }
    
    // MARK: - Read Operation Tests
    
    func testReadExistingKeychainItem() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "test_data".data(using: .utf8)!
        let account = "test_account"
        
        // Act
        let saveResult = await manager.save(testData, account: account)
        let retrievedData = await manager.read(account: account)
        
        // Assert
        XCTAssertTrue(saveResult, "Save should succeed")
        XCTAssertEqual(retrievedData, testData, "Should retrieve the same data")
    }
    
    func testReadNonExistentKeychainItem() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let nonExistentAccount = "non_existent_account"
        
        // Act
        let result = await manager.read(account: nonExistentAccount)
        
        // Assert
        XCTAssertNil(result, "Should return nil for non-existent item")
    }
    
    // MARK: - Delete Operation Tests
    
    func testDeleteExistingKeychainItem() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "test_data".data(using: .utf8)!
        let account = "test_account"
        
        // Act
        let saveResult = await manager.save(testData, account: account)
        let deleteResult = await manager.delete(account: account)
        let readResult = await manager.read(account: account)
        
        // Assert
        XCTAssertTrue(saveResult, "Save should succeed")
        XCTAssertTrue(deleteResult, "Delete should succeed")
        XCTAssertNil(readResult, "Item should not exist after deletion")
    }
    
    func testDeleteNonExistentKeychainItem() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let nonExistentAccount = "non_existent_account"
        
        // Act
        let result = await manager.delete(account: nonExistentAccount)
        
        // Assert
        XCTAssertTrue(result, "Delete should return true even for non-existent item")
    }
    
    // MARK: - Service Name Generation Tests
    
    func testServiceNameGeneration() async{
        // Arrange
        let config1 = AdelsonAuthConfig(appName: "TestApp1", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        let config2 = AdelsonAuthConfig(appName: "TestApp2", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        
        // Act
        KeychainManager.configure(with: config1)
        let manager1 = KeychainManager.shared
        
        // Reset and configure with different app name
        KeychainManager._shared = nil
        KeychainManager.configure(with: config2)
        let manager2 = KeychainManager.shared
        
        // Assert
        // Note: We can't directly test the private service property,
        // but we can verify different configs create different managers
        let appName1 = await manager1.config.appName
        let appName2 = await manager2.config.appName
        XCTAssertEqual(appName1, "TestApp1")
        XCTAssertEqual(appName2, "TestApp2")
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentAccessToSingleton() {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 10
        
        var managers: [KeychainManager] = []
        let managersLock = NSLock()
        let queue = DispatchQueue.global(qos: .background)
        
        // Act
        for _ in 0..<10 {
            queue.async {
                let manager = KeychainManager.shared
                
                managersLock.lock()
                managers.append(manager)
                managersLock.unlock()
                
                expectation.fulfill()
            }
        }
        
        // Assert
        wait(for: [expectation], timeout: 5.0)
        
        // Verify all managers are the same instance
        managersLock.lock()
        let firstManager = managers.first!
        for manager in managers {
            XCTAssertTrue(manager === firstManager, "All managers should be the same instance")
        }
        managersLock.unlock()
    }
    
    // MARK: - Integration Tests
    
    func testCompleteKeychainWorkflow() async {
        // Arrange
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "integration_test_data".data(using: .utf8)!
        let updatedData = "updated_integration_data".data(using: .utf8)!
        let account = "integration_account"
        
        // Act & Assert
        
        // 1. Save data
        let saveResult = await manager.save(testData, account: account)
        XCTAssertTrue(saveResult, "Save should succeed")
        
        // 2. Read data
        let readResult1 = await manager.read(account: account)
        XCTAssertEqual(readResult1, testData, "Should read saved data")
        
        // 3. Update data
        let updateResult = await manager.update(updatedData, account: account)
        XCTAssertTrue(updateResult, "Update should succeed")
        
        // 4. Read updated data
        let readResult2 = await manager.read(account: account)
        XCTAssertEqual(readResult2, updatedData, "Should read updated data")
        
        // 5. Delete data
        let deleteResult = await manager.delete(account: account)
        XCTAssertTrue(deleteResult, "Delete should succeed")
        
        // 6. Verify deletion
        let readResult3 = await manager.read(account: account)
        XCTAssertNil(readResult3, "Should not find deleted data")
    }
}
// MARK: - Performance Tests

extension KeychainManagerTests {
    
    func testSavePerformance() {
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "performance_test_data".data(using: .utf8)!
        
        measure {
            Task {
                for i in 0..<100 {
                    await manager.save(testData, account: "account_\(i)")
                }
            }
        }
    }
    
    func testReadPerformance() {
        let config = AdelsonAuthConfig(appName: "TestApp", baseUrl: "any", signUpEndpoint: "any", otpEndpoint: "verify-otp", loginEndpoint: "login")
        KeychainManager.configure(with: config)
        let manager = KeychainManager.shared
        let testData = "performance_test_data".data(using: .utf8)!
        let account = "performance_account"
        
        // Setup
        Task {
            await manager.save(testData, account: account)
        }
        
        measure {
            Task {
                for _ in 0..<100 {
                    await manager.read(account: account)
                }
            }
        }
    }
}
