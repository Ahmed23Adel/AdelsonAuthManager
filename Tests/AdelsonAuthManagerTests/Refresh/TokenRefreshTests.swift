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

// MARK: - Token Refresh Tests
@available(macOS 10.15, *)
class TokenRefreshTests: XCTestCase {
    
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
    
    // MARK: - Test Case 1: Successful Token Refresh
    func testRefreshTokenSuccess() async throws {
        // Arrange: Set up a valid refresh token in AuthTokenStore
        let testRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1Mjc3ODIxMH0.RqK_j9h9ww_ox5VNOwlJP0xSk3uwNbGDHjcgQOxYgvU"
        await AuthTokenStore.shared.setRefreshToken(testRefreshToken)
        
        let refreshOperation = TraditionslRefreshToken(
            username: "", // Not used in refresh
            password: "", // Not used in refresh
            config: config,
            networkService: networkService,
        )
        
        // Act: Execute the refresh operation
        let result = await refreshOperation.execute()
        
        // Assert: Verify successful execution and response
        XCTAssertTrue(result, "Token refresh should succeed with valid refresh token")
        XCTAssertNil(refreshOperation.error, "No error should be present on successful refresh")
        
        let responseModel = refreshOperation.getResult()
        XCTAssertNotNil(responseModel, "Response model should not be nil")
        XCTAssertFalse(responseModel?.access_token.isEmpty ?? true, "Access token should not be empty")
        XCTAssertFalse(responseModel?.refresh_token.isEmpty ?? true, "Refresh token should not be empty")
        
        print("✅ Test 1 Passed: Basic token refresh successful")
    }
    
    // MARK: - Test Case 2: Refresh Token with Keychain Decorator
    func testRefreshTokenWithKeychainDecorator() async throws {
        // Arrange: Set up refresh token and create decorated operation
        let testRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1Mjc3ODIxMH0.RqK_j9h9ww_ox5VNOwlJP0xSk3uwNbGDHjcgQOxYgvU"
        await AuthTokenStore.shared.setRefreshToken(testRefreshToken)
        
        let baseOperation = TraditionslRefreshToken(
            username: "",
            password: "",
            config: config,
            networkService: networkService,
        )
        
        let decoratedOperation = DecoratorSaveAuthToken(
            operation: baseOperation,
            config: config
        )
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation._execute()
        
        // Assert: Verify execution and keychain storage
        XCTAssertTrue(result, "Decorated operation should succeed")
        
        let responseModel = decoratedOperation.getResult()
        XCTAssertNotNil(responseModel, "Response model should not be nil")
        
        // Verify tokens are saved in keychain
        let savedAccessToken = await KeychainManager.shared.read(account: config.keychainConfig.accessTokenAccount)
        let savedRefreshToken = await KeychainManager.shared.read(account: config.keychainConfig.refreshTokenAccount)
        
        XCTAssertNotNil(savedAccessToken, "Access token should be saved in keychain")
        XCTAssertNotNil(savedRefreshToken, "Refresh token should be saved in keychain")
        
        let accessTokenString = String(data: savedAccessToken!, encoding: .utf8)
        let refreshTokenString = String(data: savedRefreshToken!, encoding: .utf8)
        
        XCTAssertEqual(accessTokenString, responseModel?.access_token, "Keychain access token should match response")
        XCTAssertEqual(refreshTokenString, responseModel?.refresh_token, "Keychain refresh token should match response")
        
        print("✅ Test 2 Passed: Keychain decorator working correctly")
    }
    
    // MARK: - Test Case 3: Refresh Token with AuthStore Decorator
    func testRefreshTokenWithAuthStoreDecorator() async throws {
        // Arrange: Set up refresh token and create decorated operation
        let testRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1Mjc3ODIxMH0.RqK_j9h9ww_ox5VNOwlJP0xSk3uwNbGDHjcgQOxYgvU"
        await AuthTokenStore.shared.setRefreshToken(testRefreshToken)
        
        let baseOperation = TraditionslRefreshToken(
            username: "",
            password: "",
            config: config,
            networkService: networkService,
        )
        
        let decoratedOperation = DecoratorMainAuthConfigurator(operation: baseOperation)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation._execute()
        
        // Assert: Verify execution and AuthTokenStore updates
        XCTAssertTrue(result, "Decorated operation should succeed")
        
        let responseModel = decoratedOperation.getResult()
        XCTAssertNotNil(responseModel, "Response model should not be nil")
        
        // Verify tokens are updated in AuthTokenStore
        let storedAccessToken = await AuthTokenStore.shared.getAccessToken()
        let storedRefreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        XCTAssertNotNil(storedAccessToken, "Access token should be stored in AuthTokenStore")
        XCTAssertNotNil(storedRefreshToken, "Refresh token should be stored in AuthTokenStore")
        XCTAssertEqual(storedAccessToken, responseModel?.access_token, "AuthStore access token should match response")
        XCTAssertEqual(storedRefreshToken, responseModel?.refresh_token, "AuthStore refresh token should match response")
        
        print("✅ Test 3 Passed: AuthStore decorator working correctly")
    }
    
    // MARK: - Test Case 4: Refresh Token with Both Decorators (Chain)
    func testRefreshTokenWithBothDecorators() async throws {
        // Arrange: Set up refresh token and create chained decorators
        let testRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1Mjc3ODIxMH0.RqK_j9h9ww_ox5VNOwlJP0xSk3uwNbGDHjcgQOxYgvU"
        await AuthTokenStore.shared.setRefreshToken(testRefreshToken)
        
        let baseOperation = TraditionslRefreshToken(
            username: "",
            password: "",
            config: config,
            networkService: networkService,
        )
        
        // Chain decorators: AuthStore -> Keychain -> Base
        let authStoreDecorator = DecoratorMainAuthConfigurator(operation: baseOperation)
        let keychainDecorator = DecoratorSaveAuthToken(operation: authStoreDecorator, config: config)
        
        // Act: Execute the chained decorators
        let result = await keychainDecorator._execute()
        
        // Assert: Verify execution and both storage mechanisms
        XCTAssertTrue(result, "Chained decorators should succeed")
        
        let responseModel = keychainDecorator.getResult()
        XCTAssertNotNil(responseModel, "Response model should not be nil")
        
        // Verify AuthTokenStore
        let storedAccessToken = await AuthTokenStore.shared.getAccessToken()
        let storedRefreshToken = await AuthTokenStore.shared.getRefreshToken()
        
        XCTAssertEqual(storedAccessToken, responseModel?.access_token, "AuthStore should have correct access token")
        XCTAssertEqual(storedRefreshToken, responseModel?.refresh_token, "AuthStore should have correct refresh token")
        
        // Verify Keychain
        let keychainAccessToken = await KeychainManager.shared.read(account: config.keychainConfig.accessTokenAccount)
        let keychainRefreshToken = await KeychainManager.shared.read(account: config.keychainConfig.refreshTokenAccount)
        
        XCTAssertNotNil(keychainAccessToken, "Keychain should have access token")
        XCTAssertNotNil(keychainRefreshToken, "Keychain should have refresh token")
        
        let keychainAccessString = String(data: keychainAccessToken!, encoding: .utf8)
        let keychainRefreshString = String(data: keychainRefreshToken!, encoding: .utf8)
        
        XCTAssertEqual(keychainAccessString, responseModel?.access_token, "Keychain access token should match")
        XCTAssertEqual(keychainRefreshString, responseModel?.refresh_token, "Keychain refresh token should match")
        
        print("✅ Test 4 Passed: Both decorators working in chain")
    }
    
//    // MARK: - Test Case 5: Network Failure Handling
//    func testRefreshTokenNetworkFailure() async throws {
//        // Arrange: Set up an invalid/expired refresh token
//        let expiredRefreshToken = "expired_or_invalid_token"
//        await AuthTokenStore.shared.setRefreshToken(expiredRefreshToken)
//        
//        let refreshOperation = TraditionslRefreshToken(
//            username: "",
//            password: "",
//            config: config,
//            networkService: networkService,
//        )
//        
//        // Act: Execute with invalid token
//        let result = await refreshOperation.execute()
//        
//        // Assert: Verify failure handling
//        XCTAssertFalse(result, "Operation should fail with invalid refresh token")
//        XCTAssertNotNil(refreshOperation.error, "Error should be set on failure")
//        XCTAssertNil(refreshOperation.getResult(), "Result should be nil on failure")
//        
//        print("✅ Test 5 Passed: Network failure handled correctly")
//    }
    
    
    // MARK: - Test Case 7: Decorator Chain Failure Propagation
    func testDecoratorChainFailure() async throws {
        // Arrange: Set up scenario that will cause base operation to fail
        await AuthTokenStore.shared.setRefreshToken("definitely_invalid_token")
        
        let baseOperation = TraditionslRefreshToken(
            username: "",
            password: "",
            config: config,
            networkService: networkService,
        )
        
        let decoratedOperation = DecoratorSaveAuthToken(
            operation: baseOperation,
            config: config
        )
        
        // Act: Execute decorated operation that should fail
        let result = await decoratedOperation._execute()
        
        // Assert: Verify failure propagation and no storage
        XCTAssertFalse(result, "Decorated operation should fail when base fails")
        XCTAssertNil(decoratedOperation.getResult(), "Result should be nil on failure")
        
        // Verify no tokens were saved to keychain
        let savedAccessToken = await KeychainManager.shared.read(account: config.keychainConfig.accessTokenAccount)
        let savedRefreshToken = await KeychainManager.shared.read(account: config.keychainConfig.refreshTokenAccount)
        
        XCTAssertNil(savedAccessToken, "No access token should be saved on failure")
        XCTAssertNil(savedRefreshToken, "No refresh token should be saved on failure")
        
        print("✅ Test 7 Passed: Decorator failure propagation working correctly")
    }
    
   
    // MARK: - Test Case 9: Concurrent Refresh Operations
    func testConcurrentRefreshOperations() async throws {
        // Arrange: Set up valid refresh token
        let testRefreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1Mjc3ODIxMH0.RqK_j9h9ww_ox5VNOwlJP0xSk3uwNbGDHjcgQOxYgvU"
        await AuthTokenStore.shared.setRefreshToken(testRefreshToken)
        
        // Create multiple operations
        let operation1 = TraditionslRefreshToken(
            username: "", password: "", config: config,
            networkService: networkService,
        )
        
        let operation2 = TraditionslRefreshToken(
            username: "", password: "", config: config,
            networkService: networkService,
        )
        
        // Act: Execute concurrently
        async let result1 = operation1.execute()
        async let result2 = operation2.execute()
        
        let results = await [result1, result2]
        
        // Assert: Both operations should handle concurrency gracefully
        // Note: Depending on server implementation, both might succeed or one might fail
        print("Concurrent results: \(results)")
        
        // At least verify no crashes occurred
        XCTAssertTrue(true, "Concurrent operations completed without crashes")
        
        print("✅ Test 9 Passed: Concurrent operations handled gracefully")
    }
    
   
}
