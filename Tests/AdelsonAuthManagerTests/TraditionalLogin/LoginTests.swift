//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

import XCTest
import Foundation
@testable import AdelsonAuthManager

import XCTest
import Foundation


// MARK: - Test Configuration Extensions
extension AdelsonAuthConfig {
    static func createTestConfig() -> AdelsonAuthConfig {
        return AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh",
            
        )
    }
}

// MARK: - Test Configuration
@available(macOS 10.15, *)
class LoginTests: XCTestCase {
    
    var config: AdelsonAuthConfig!
    var networkService: AlamoFireNetworkService!
    var keychainManager: KeychainManager!
    
    override func setUp() {
        super.setUp()
        
        // Configure test environment
        config = AdelsonAuthConfig.createTestConfig()
        
        networkService = AlamoFireNetworkService()
        
        // Configure KeychainManager
        KeychainManager.configure(with: config)
        
        // Clean up any existing tokens synchronously
        cleanupTestDataSync()
    }
    
    override func tearDown() {
        cleanupTestDataSync()
        super.tearDown()
    }
    
    private func cleanupTestDataSync() {
        let semaphore = DispatchSemaphore(value: 0)
        let accessTokenAccount = config.keychainConfig.accessTokenAccount
        let refreshTokenAccount = config.keychainConfig.refreshTokenAccount
        
        Task.detached {
            await KeychainManager.shared.delete(account: accessTokenAccount)
            await KeychainManager.shared.delete(account: refreshTokenAccount)
            await AuthTokenStore.shared.setAccessToken(nil)
            await AuthTokenStore.shared.setRefreshToken(nil)
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    // MARK: - Test Case 1: Basic Traditional Login Success
    func testTraditionalLoginSuccess() async {
        // Arrange
        let username = "ahmed"
        let password = "any"
        let traditionalLogin = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = await traditionalLogin.execute()
        
        // Assert
        XCTAssertTrue(result, "Login should succeed with valid credentials")
        XCTAssertNotNil(traditionalLogin.getResult(), "Result should not be nil after successful login")
        
        let response = traditionalLogin.getResult()!
        XCTAssertFalse(response.access_token.isEmpty, "Access token should not be empty")
        XCTAssertFalse(response.refresh_token.isEmpty, "Refresh token should not be empty")
        XCTAssertEqual(traditionalLogin.getUserName(), username, "Username should match")
        XCTAssertEqual(traditionalLogin.getPassword(), password, "Password should match")
    }
    
    // MARK: - Test Case 2: Traditional Login with Invalid Credentials
    func testTraditionalLoginFailure() async {
        // Arrange
        let username = "invalid_user"
        let password = "invalid_password"
        let traditionalLogin = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = await traditionalLogin.execute()
        
        // Assert
        XCTAssertFalse(result, "Login should fail with invalid credentials")
        XCTAssertNil(traditionalLogin.getResult(), "Result should be nil after failed login")
    }
    
    // MARK: - Test Case 3: Login with Extra User Info
    func testTraditionalLoginWithExtraUserInfo() async {
        // Arrange
        let username = "ahmed"
        let password = "any"
        let extraInfo = ["device_id": "test_device_123", "app_version": "1.0.0"]
        let traditionalLogin = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraInfo,
            networkService: networkService
        )
        
        // Act
        let result = await traditionalLogin.execute()
        
        // Assert
        XCTAssertTrue(result, "Login should succeed")
        XCTAssertEqual(traditionalLogin.getExtraUserInfo(key: "device_id"), "test_device_123")
        XCTAssertEqual(traditionalLogin.getExtraUserInfo(key: "app_version"), "1.0.0")
        XCTAssertEqual(traditionalLogin.getExtraUserInfo(key: "nonexistent"), "", "Should return empty string for nonexistent key")
    }
    
    // MARK: - Test Case 4: Keychain Save Decorator - Success Flow
    func testDecoratorSaveAuthTokenSuccess() async {
        // Arrange
        let username = "ahmed"
        let password = "any"
        let baseOperation = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        var saveTokenDecorator = DecoratorSaveAuthToken(operation: baseOperation, config: config)
        
        // Act
        let result = await saveTokenDecorator.execute()
        
        // Assert
        XCTAssertTrue(result, "Decorated operation should succeed")
        
        // Verify tokens are saved in keychain
        let savedAccessToken = await KeychainManager.shared.read(account: config.keychainConfig.accessTokenAccount)
        let savedRefreshToken = await KeychainManager.shared.read(account: config.keychainConfig.refreshTokenAccount)
        
        XCTAssertNotNil(savedAccessToken, "Access token should be saved in keychain")
        XCTAssertNotNil(savedRefreshToken, "Refresh token should be saved in keychain")

        let accessTokenString = String(data: savedAccessToken!, encoding: .utf8)
        let refreshTokenString = String(data: savedRefreshToken!, encoding: .utf8)
        
        XCTAssertFalse(accessTokenString!.isEmpty, "Access token should not be empty")
        XCTAssertFalse(refreshTokenString!.isEmpty, "Refresh token should not be empty")
        
        // Verify we can still get the result
        let response = saveTokenDecorator.getResult()
        XCTAssertNotNil(response, "Should be able to get result from decorator")
        XCTAssertEqual(response!.access_token, accessTokenString!, "Access token should match")
        XCTAssertEqual(response!.refresh_token, refreshTokenString!, "Refresh token should match")
    }
    
    // MARK: - Test Case 5: Keychain Save Decorator - Failure Flow
    func testDecoratorSaveAuthTokenFailure() async {
        // Arrange
        let username = "invalid_user"
        let password = "invalid_password"
        let baseOperation = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        let saveTokenDecorator = DecoratorSaveAuthToken(operation: baseOperation, config: config)
        
        // Act
        let result = await saveTokenDecorator._execute()
        
        // Assert
        XCTAssertFalse(result, "Decorated operation should fail")
        
        // Verify no tokens are saved in keychain
        let savedAccessToken = await KeychainManager.shared.read(account: config.keychainConfig.accessTokenAccount)
        let savedRefreshToken = await KeychainManager.shared.read(account: config.keychainConfig.refreshTokenAccount)
        
        XCTAssertNil(savedAccessToken, "Access token should not be saved on failure")
        XCTAssertNil(savedRefreshToken, "Refresh token should not be saved on failure")
    }
    
    // MARK: - Test Case 6: Main Auth Configurator Decorator - Success Flow
    func testDecoratorMainAuthConfiguratorSuccess() async {
        // Arrange
        let username = "ahmed"
        let password = "any"
        let baseOperation = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        var mainAuthDecorator = DecoratorMainAuthConfigurator(operation: baseOperation)
        
        // Act
        let result = await mainAuthDecorator.execute()
        
        // Assert
        XCTAssertTrue(result, "Main auth decorator should succeed")
        
        // Verify tokens are set in AuthTokenStore
        let storedAccessToken = await AuthTokenStore.shared.getAccessToken()
        let storedRefreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        XCTAssertNotNil(storedAccessToken, "Access token should be stored in AuthTokenStore")
        XCTAssertNotNil(storedRefreshToken, "Refresh token should be stored in AuthTokenStore")
        XCTAssertFalse(storedAccessToken!.isEmpty, "Access token should not be empty")
        XCTAssertFalse(storedRefreshToken!.isEmpty, "Refresh token should not be empty")
        
        // Verify we can still get the result
        let response = mainAuthDecorator.getResult()
        XCTAssertNotNil(response, "Should be able to get result from decorator")
        XCTAssertEqual(response!.access_token, storedAccessToken!, "Access token should match")
        XCTAssertEqual(response!.refresh_token, storedRefreshToken!, "Refresh token should match")
    }
    
    // MARK: - Test Case 7: Main Auth Configurator Decorator - Failure Flow
    func testDecoratorMainAuthConfiguratorFailure() async {
        // Arrange
        let username = "invalid_user"
        let password = "invalid_password"
        let baseOperation = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        let mainAuthDecorator = DecoratorMainAuthConfigurator(operation: baseOperation)
        
        // Act
        let result = await mainAuthDecorator._execute()
        
        // Assert
        XCTAssertFalse(result, "Main auth decorator should fail")
        
        // Verify no tokens are set in AuthTokenStore
        let storedAccessToken = await AuthTokenStore.shared.getAccessToken()
        let storedRefreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        XCTAssertNil(storedAccessToken, "Access token should not be stored on failure")
        XCTAssertNil(storedRefreshToken, "Refresh token should not be stored on failure")
    }
    
    // MARK: - Test Case 8: Combined Decorators - Success Flow
    func testCombinedDecoratorsSuccess() async {
        // Arrange
        let username = "ahmed"
        let password = "any"
        let baseOperation = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Chain decorators: base -> save tokens -> main auth configurator
        let saveTokenDecorator = DecoratorSaveAuthToken(operation: baseOperation, config: config)
        var mainAuthDecorator = DecoratorMainAuthConfigurator(operation: saveTokenDecorator)
        
        // Act
        let result = await mainAuthDecorator.execute()
        
        // Assert
        XCTAssertTrue(result, "Combined decorators should succeed")
        
        // Verify tokens are in keychain
        let savedAccessToken = await KeychainManager.shared.read(account: config.keychainConfig.accessTokenAccount)
        let savedRefreshToken = await KeychainManager.shared.read(account: config.keychainConfig.refreshTokenAccount)
        
        XCTAssertNotNil(savedAccessToken, "Access token should be saved in keychain")
        XCTAssertNotNil(savedRefreshToken, "Refresh token should be saved in keychain")
        
        // Verify tokens are in AuthTokenStore
        let storedAccessToken = await AuthTokenStore.shared.getAccessToken()
        let storedRefreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        XCTAssertNotNil(storedAccessToken, "Access token should be stored in AuthTokenStore")
        XCTAssertNotNil(storedRefreshToken, "Refresh token should be stored in AuthTokenStore")
        
        // Verify consistency between keychain and AuthTokenStore
        let accessTokenString = String(data: savedAccessToken!, encoding: .utf8)
        let refreshTokenString = String(data: savedRefreshToken!, encoding: .utf8)
        
        XCTAssertEqual(accessTokenString, storedAccessToken, "Access tokens should match between keychain and store")
        XCTAssertEqual(refreshTokenString, storedRefreshToken, "Refresh tokens should match between keychain and store")
    }
    
    // MARK: - Test Case 9: Keychain Manager CRUD Operations
    func testKeychainManagerCRUDOperations() async {
        // Arrange
        let testAccount = "test_account"
        let testData = "test_token_data".data(using: .utf8)!
        let updatedData = "updated_token_data".data(using: .utf8)!
        
        // Test Save
        let saveResult = await KeychainManager.shared.save(testData, account: testAccount)
        XCTAssertTrue(saveResult, "Save operation should succeed")
        
        // Test Read
        let readData = await KeychainManager.shared.read(account: testAccount)
        XCTAssertNotNil(readData, "Read operation should return data")
        XCTAssertEqual(readData, testData, "Read data should match saved data")
        
        // Test Update
        let updateResult = await KeychainManager.shared.update(updatedData, account: testAccount)
        XCTAssertTrue(updateResult, "Update operation should succeed")
        
        // Verify Update
        let updatedReadData = await KeychainManager.shared.read(account: testAccount)
        XCTAssertEqual(updatedReadData, updatedData, "Read data should match updated data")
        
        // Test Delete
        let deleteResult = await KeychainManager.shared.delete(account: testAccount)
        XCTAssertTrue(deleteResult, "Delete operation should succeed")
        
        // Verify Delete
        let deletedReadData = await KeychainManager.shared.read(account: testAccount)
        XCTAssertNil(deletedReadData, "Read operation should return nil after deletion")
    }
    
    // MARK: - Test Case 10: AuthTokenStore Operations
    func testAuthTokenStoreOperations() async {
        // Arrange
        let testAccessToken = "test_access_token_123"
        let testRefreshToken = "test_refresh_token_456"
        
        // Test setting tokens
        await AuthTokenStore.shared.setAccessToken(testAccessToken)
        await AuthTokenStore.shared.setRefreshToken(testRefreshToken)
        
        // Test getting tokens
        let retrievedAccessToken = await AuthTokenStore.shared.getAccessToken()
        let retrievedRefreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        // Assert
        XCTAssertEqual(retrievedAccessToken, testAccessToken, "Access token should match")
        XCTAssertEqual(retrievedRefreshToken, testRefreshToken, "Refresh token should match")
        
        // Test setting nil tokens
        await AuthTokenStore.shared.setAccessToken(nil)
        await AuthTokenStore.shared.setRefreshToken(nil)
        
        let nilAccessToken = await AuthTokenStore.shared.getAccessToken()
        let nilRefreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        XCTAssertNil(nilAccessToken, "Access token should be nil after setting to nil")
        XCTAssertNil(nilRefreshToken, "Refresh token should be nil after setting to nil")
    }
    
    // MARK: - Test Case 11: Token Validation Test
    func testTokenValidation() async {
        // Arrange - First login to get valid tokens
        let username = "ahmed"
        let password = "any"
        let baseOperation = TraditionalLogIn(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        let mainAuthDecorator = DecoratorMainAuthConfigurator(operation: baseOperation)
        
        // Act - Login and get tokens
        let loginResult = await mainAuthDecorator._execute()
        XCTAssertTrue(loginResult, "Login should succeed")
        
        // Get the stored tokens
        let accessToken = await AuthTokenStore.shared.getAccessToken()
        let refreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        // Assert - Verify tokens are valid (not empty and properly formatted)
        XCTAssertNotNil(accessToken, "Access token should not be nil")
        XCTAssertNotNil(refreshToken, "Refresh token should not be nil")
        XCTAssertFalse(accessToken!.isEmpty, "Access token should not be empty")
        XCTAssertFalse(refreshToken!.isEmpty, "Refresh token should not be empty")
        
        // Basic token format validation (assuming JWT format)
        let accessTokenParts = accessToken!.components(separatedBy: ".")
        let refreshTokenParts = refreshToken!.components(separatedBy: ".")
        
        // JWT tokens should have 3 parts separated by dots
        XCTAssertEqual(accessTokenParts.count, 3, "Access token should have JWT format with 3 parts")
        XCTAssertEqual(refreshTokenParts.count, 3, "Refresh token should have JWT format with 3 parts")
        
        // Verify each part is base64 encoded (not empty)
        for part in accessTokenParts {
            XCTAssertFalse(part.isEmpty, "Access token parts should not be empty")
        }
        for part in refreshTokenParts {
            XCTAssertFalse(part.isEmpty, "Refresh token parts should not be empty")
        }
    }
    
    // MARK: - Test Case 12: Error Handling
    func testErrorHandling() async {
        // Arrange - Try to access nonexistent keychain item
        let nonExistentAccount = "nonexistent_account"
        
        // Act & Assert
        let nonExistentData = await KeychainManager.shared.read(account: nonExistentAccount)
        XCTAssertNil(nonExistentData, "Reading nonexistent keychain item should return nil")
        
        // Test deleting nonexistent item
        let deleteResult = await KeychainManager.shared.delete(account: nonExistentAccount)
        XCTAssertTrue(deleteResult, "Deleting nonexistent item should return true")
        
        // Test updating nonexistent item
        let testData = "test_data".data(using: .utf8)!
        let updateResult = await KeychainManager.shared.update(testData, account: nonExistentAccount)
        XCTAssertFalse(updateResult, "Updating nonexistent item should return false")
    }
    
    // MARK: - Test Case 13: Edge Cases
    func testEdgeCases() async {
        // Test with empty strings
        let emptyLogin = TraditionalLogIn(
            username: "",
            password: "",
            config: config,
            networkService: networkService
        )
        
        let emptyResult = await emptyLogin.execute()
        XCTAssertFalse(emptyResult, "Login with empty credentials should fail")
        
        // Test with very long strings
        let longString = String(repeating: "a", count: 10000)
        let longLogin = TraditionalLogIn(
            username: longString,
            password: longString,
            config: config,
            networkService: networkService
        )
        
        let longResult = await longLogin.execute()
        XCTAssertFalse(longResult, "Login with very long credentials should fail")
    }
}
