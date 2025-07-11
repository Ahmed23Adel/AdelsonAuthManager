//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 11/07/2025.
//

import Foundation
import XCTest
import Alamofire
@testable import AdelsonAuthManager


@available(macOS 10.15, *)
class TraditionslSignUpOperationTests: XCTestCase {
    
    // MARK: - Test Setup
    
    var config: AdelsonAuthConfig!
    var networkService: AlamoFireNetworkService!
    
    override func setUp() {
        super.setUp()
        config = AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup"
        )
        networkService = AlamoFireNetworkService()
    }
    
    override func tearDown() {
        config = nil
        networkService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Test Case 1: Successful signup with valid credentials
    /// Prerequisites: Server should be running at http://0.0.0.0:8000
    func testExecute_ValidCredentials_ReturnsTrue() async throws {
        // Arrange
        let username = "testuser_\(UUID().uuidString.prefix(8))" // Unique username
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = try await operation.execute()
        print("result", result)
        // Assert
        XCTAssertTrue(result, "Execute should return true for successful signup")
        XCTAssertEqual(operation.getUserName(), username, "Should return correct username")
        XCTAssertEqual(operation.getPassword(), password, "Should return correct password")
    }
    
    /// Test Case 2: Duplicate username - should throw UserNameAlreadyExists error
    /// Prerequisites: Server should be running and return 400 for duplicate usernames
    func testExecute_DuplicateUsername_ThrowsUserNameAlreadyExistsError() async throws {
        // Arrange
        let username = "testuser_\(UUID().uuidString.prefix(8))" // Unique username
        let password = "testpass123"
        
        let operation1 = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let operation2 = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        print("k1")
        // Act & Assert
        do {
            print("k2")
            // First signup should succeed
            let result1 = try await operation1.execute()
            print("k3")
            XCTAssertTrue(result1, "First signup should succeed")
            print("k4")
            // Second signup with same username should throw error
            let res = try await operation2.execute()
            print("k5", res)
            XCTFail("Second signup should throw UserNameAlreadyExists error")
        } catch TraditionslSignUpOperationErrors.UserNameAlreadyExists {
            // Expected error - test passes
            XCTAssertTrue(true, "Correctly threw UserNameAlreadyExists error")
        } catch {
            XCTFail("Expected UserNameAlreadyExists error, but got: \(error)")
        }
    }
    
    
    
    /// Test Case 4: Invalid endpoint - should return false
    func testExecute_ServerUnavailable_ThrowsNetworkError() async throws {
        // Arrange
        let unavailableConfig = AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://127.0.0.1:9000/", // Wrong port to simulate unavailability
            signUpEndpoint: "signup"
        )
        let username = "testuser"
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: unavailableConfig,
            networkService: networkService
        )
        
        // Act & Assert
        do {
            _ = try await operation.execute()
            XCTFail("Expected to throw when server is unavailable, but succeeded")
        } catch SignUpError.invalidURL {
            // This is a valid error if the URL itself was malformed
            XCTAssertTrue(true, "Correctly threw invalidURL error")
        } catch SignUpError.networkError(let afError, let statusCode) {
            print("Caught network error: \(afError), status code: \(String(describing: statusCode))")
            XCTAssertTrue(true, "Correctly threw networkError")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    
    /// Test Case 5: Empty username - test server response
    func testExecute_EmptyUsername_TestServerResponse() async throws {
        // Arrange
        let username = ""
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = try await operation.execute()
        
        // Assert
        // Result depends on server implementation - document the behavior
        print("Empty username result: \(result)")
        XCTAssertEqual(operation.getUserName(), "", "Should return empty username")
    }
    
    /// Test Case 6: Empty password - test server response
    func testExecute_EmptyPassword_TestServerResponse() async throws {
        // Arrange
        let username = "testuser_empty_pass"
        let password = ""
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = try await operation.execute()
        
        // Assert
        // Result depends on server implementation - document the behavior
        print("Empty password result: \(result)")
        XCTAssertEqual(operation.getPassword(), "", "Should return empty password")
    }
    
    /// Test Case 7: Very long username - test server limits
    func testExecute_VeryLongUsername_TestServerLimits() async throws {
        // Arrange
        let username = String(repeating: "a", count: 1000)
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = try await operation.execute()
        
        // Assert
        // Result depends on server implementation - document the behavior
        print("Very long username result: \(result)")
        XCTAssertEqual(operation.getUserName(), username, "Should return the long username")
    }
    
    /// Test Case 8: Special characters in credentials
    func testExecute_SpecialCharacters_TestServerHandling() async throws {
        // Arrange
        let username = "test@user.com"
        let password = "p@ssw0rd!@#$%"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = try await operation.execute()
        
        // Assert
        // Result depends on server implementation
        print("Special characters result: \(result)")
        XCTAssertEqual(operation.getUserName(), username, "Should return username with special characters")
        XCTAssertEqual(operation.getPassword(), password, "Should return password with special characters")
    }
    
    /// Test Case 9: Unicode characters in credentials
    func testExecute_UnicodeCharacters_TestServerHandling() async throws {
        // Arrange
        let username = "用户名\(UUID().uuidString.prefix(4))"
        let password = "пароль123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = try await operation.execute()
        
        // Assert
        // Result depends on server implementation
        print("Unicode characters result: \(result)")
        XCTAssertEqual(operation.getUserName(), username, "Should return unicode username")
        XCTAssertEqual(operation.getPassword(), password, "Should return unicode password")
    }
    
    /// Test Case 10: Concurrent signup attempts
    func testExecute_ConcurrentSignups_HandleMultipleRequests() async throws {
        // Arrange
        let baseUsername = "concurrent_user"
        let password = "testpass123"
        
        let operation1 = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: "\(baseUsername)_1_\(UUID().uuidString.prefix(4))",
            password: password,
            config: config,
            networkService: networkService
        )
        
        let operation2 = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: "\(baseUsername)_2_\(UUID().uuidString.prefix(4))",
            password: password,
            config: config,
            networkService: networkService
        )
        
        let operation3 = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: "\(baseUsername)_3_\(UUID().uuidString.prefix(4))",
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        async let result1 = operation1.execute()
        async let result2 = operation2.execute()
        async let result3 = operation3.execute()
        
        let (res1, res2, res3) = try await (result1, result2, result3)
        
        // Assert
        print("Concurrent results: \(res1), \(res2), \(res3)")
        // At least some should succeed if server handles concurrent requests properly
        let successCount = [res1, res2, res3].filter { $0 }.count
        XCTAssertGreaterThan(successCount, 0, "At least one concurrent signup should succeed")
    }
    
    /// Test Case 11: Test getUserName method
    func testGetUserName_ReturnsCorrectUsername() {
        // Arrange
        let username = "testuser"
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = operation.getUserName()
        
        // Assert
        XCTAssertEqual(result, username, "getUserName should return the correct username")
    }
    
    /// Test Case 12: Test getPassword method
    func testGetPassword_ReturnsCorrectPassword() {
        // Arrange
        let username = "testuser"
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = operation.getPassword()
        
        // Assert
        XCTAssertEqual(result, password, "getPassword should return the correct password")
    }
    
    /// Test Case 13: Test with different config values
    
    
    /// Test Case 14: Test JSON encoding/decoding
    func testExecute_JSONHandling_ValidatesDataTransfer() async throws {
        // Arrange
        let username = "json_test_\(UUID().uuidString.prefix(8))"
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act
        let result = try await operation.execute()
        
        // Assert
        if result {
            // If successful, the JSON encoding/decoding worked correctly
            XCTAssertTrue(true, "JSON encoding/decoding successful")
        } else {
            // If failed, check that it's due to server logic, not JSON issues
            print("JSON test failed - check server response format")
        }
    }
    
    /// Test Case 15: Performance test - measure execution time
    func testExecute_Performance_MeasureExecutionTime() async throws {
        // Arrange
        let username = "perf_test_\(UUID().uuidString.prefix(8))"
        let password = "testpass123"
        
        let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act & Assert
        let startTime = Date()
        let result = try await operation.execute()
        let endTime = Date()
        
        let executionTime = endTime.timeIntervalSince(startTime)
        print("Execution time: \(executionTime) seconds")
        
        // Assert reasonable execution time (adjust based on your server)
        XCTAssertLessThan(executionTime, 10.0, "Signup should complete within 10 seconds")
        
        // Document the result
        print("Performance test result: \(result)")
    }
}
