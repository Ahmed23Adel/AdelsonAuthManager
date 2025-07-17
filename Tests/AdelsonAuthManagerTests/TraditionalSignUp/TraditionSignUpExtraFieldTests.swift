//
//  TraditionSignUpExtraFieldTests.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//


@testable import AdelsonValidator
@testable import AdelsonAuthManager

import XCTest
import Foundation

@available(macOS 13.0.0, *)
class TraditionSignUpExtraFieldTests: XCTestCase {
    
    // MARK: - Test Setup
    
    var config: AdelsonAuthConfig!
    var networkService: AlamoFireNetworkService!
    
    override func setUp() {
        super.setUp()
        config = AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup", otpEndpoint: "verify-otp", loginEndpoint: "login",
        )
        networkService = AlamoFireNetworkService()
    }
    
    override func tearDown() {
        config = nil
        networkService = nil
        super.tearDown()
    }
    
    // MARK: - Extra Field Basic Tests
    
    func testSignUpWithSingleExtraField() async throws {
        // Arrange: Set up operation with extra field
        let username = "test@example.com"
        let password = "ValidPass123"
        let extraFields = ["firstName": "John"]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify successful sign-up with extra field
        XCTAssertTrue(result, "Sign-up should succeed with valid extra field")
        XCTAssertNil(baseOperation.getError(), "Error should be nil for successful sign-up")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "firstName"), "John", "Extra field should be accessible")
    }
    
    func testSignUpWithMultipleExtraFields() async throws {
        // Arrange: Set up operation with multiple extra fields
        let username = "test2@example.com"
        let password = "ValidPass123"
        let extraFields = [
            "firstName": "John",
            "lastName": "Doe",
            "phoneNumber": "1234567890",
            "dateOfBirth": "1990-01-01"
        ]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify successful sign-up with multiple extra fields
        XCTAssertTrue(result, "Sign-up should succeed with multiple extra fields")
        XCTAssertNil(baseOperation.getError(), "Error should be nil for successful sign-up")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "firstName"), "John", "First name should be accessible")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "lastName"), "Doe", "Last name should be accessible")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "phoneNumber"), "1234567890", "Phone number should be accessible")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "dateOfBirth"), "1990-01-01", "Date of birth should be accessible")
    }
    
    func testSignUpWithEmptyExtraFields() async throws {
        // Arrange: Set up operation with empty extra fields
        let username = "test3@example.com"
        let password = "ValidPass123"
        let extraFields: [String: String] = [:]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify successful sign-up with empty extra fields
        XCTAssertTrue(result, "Sign-up should succeed with empty extra fields")
        XCTAssertNil(baseOperation.getError(), "Error should be nil for successful sign-up")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "nonExistent"), "", "Non-existent field should return empty string")
    }
    
    func testSignUpWithNilExtraFields() async throws {
        // Arrange: Set up operation with nil extra fields
        let username = "test4@example.com"
        let password = "ValidPass123"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify successful sign-up with nil extra fields
        XCTAssertTrue(result, "Sign-up should succeed with nil extra fields")
        XCTAssertNil(baseOperation.getError(), "Error should be nil for successful sign-up")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "nonExistent"), "", "Non-existent field should return empty string")
    }
    
    // MARK: - Extra Field Decorator Validation Tests
    
    func testExtraFieldDecoratorWithValidInput() async throws {
        // Arrange: Set up operation with extra field decorator
        let username = "test5@example.com"
        let password = "ValidPass123"
        let extraFields = ["firstName": "John"]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Create a simple validation policy for first name (minimum 2 characters)
        let validators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 2),
            StringHasMaxLen(maxLen: 50)
        ]
        let namePolicy = SingleInputPolicy(singleInputValidators: validators)
        
        var decoratedOperation = DecoratorExtraField(
            operation: baseOperation,
            key: "firstName",
            policy: namePolicy
        )
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify successful validation
        XCTAssertTrue(result, "Extra field validation should succeed with valid input")
        XCTAssertNil(decoratedOperation.error, "Error should be nil for successful validation")
        XCTAssertEqual(decoratedOperation.getExtraUserInfo(key: "firstName"), "John", "Extra field should be accessible")
    }
    
    func testExtraFieldDecoratorWithInvalidInput() async throws {
        // Arrange: Set up operation with invalid extra field
        let username = "test6@example.com"
        let password = "ValidPass123"
        let extraFields = ["firstName": "J"] // Too short
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Create a validation policy for first name (minimum 2 characters)
        let validators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 2),
            StringHasMaxLen(maxLen: 50)
        ]
        let namePolicy = SingleInputPolicy(singleInputValidators: validators)
        
        var decoratedOperation = DecoratorExtraField(
            operation: baseOperation,
            key: "firstName",
            policy: namePolicy
        )
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify validation failure
        XCTAssertFalse(result, "Extra field validation should fail with invalid input")
        XCTAssertNotNil(decoratedOperation.getError(), "Error should be captured for invalid input")
    }
    
    func testExtraFieldDecoratorWithMissingField() async throws {
        // Arrange: Set up operation without the required extra field
        let username = "test7@example.com"
        let password = "ValidPass123"
        let extraFields: [String: String] = [:] // Missing firstName
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Create a validation policy for first name (minimum 2 characters)
        let validators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 2),
            StringHasMaxLen(maxLen: 50)
        ]
        var namePolicy = SingleInputPolicy(singleInputValidators: validators)
        
        var decoratedOperation = DecoratorExtraField(
            operation: baseOperation,
            key: "firstName",
            policy: namePolicy
        )
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify validation failure for missing field
        XCTAssertFalse(result, "Extra field validation should fail with missing field")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for missing field")
    }
    
    // MARK: - Multiple Extra Field Decorators Tests
    
    func testMultipleExtraFieldDecorators() async throws {
        // Arrange: Set up operation with multiple extra field decorators
        let username = "test8@example.com"
        let password = "ValidPass123"
        let extraFields = [
            "firstName": "John",
            "lastName": "Doe",
            "phoneNumber": "1234567890"
        ]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Create validation policies
        let nameValidators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 2),
            StringHasMaxLen(maxLen: 50)
        ]
        var namePolicy = SingleInputPolicy(singleInputValidators: nameValidators)
        
        var phoneValidators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 10),
            StringHasMaxLen(maxLen: 15),
        ]
        let phonePolicy = SingleInputPolicy(singleInputValidators: phoneValidators)
        
        // Chain decorators
        let firstNameDecorator = DecoratorExtraField(
            operation: baseOperation,
            key: "firstName",
            policy: namePolicy
        )
        
        let lastNameDecorator = DecoratorExtraField(
            operation: firstNameDecorator,
            key: "lastName",
            policy: namePolicy
        )
        
        var phoneDecorator = DecoratorExtraField(
            operation: lastNameDecorator,
            key: "phoneNumber",
            policy: phonePolicy
        )
        
        // Act: Execute the fully decorated operation
        var result = await phoneDecorator.execute()
        
        // Assert: Verify successful validation of all extra fields
        XCTAssertTrue(result, "All extra field validations should succeed")
        XCTAssertNil(phoneDecorator.error, "Error should be nil for successful validation")
    }
    
    func testMultipleExtraFieldDecoratorsWithOneFailure() async throws {
        // Arrange: Set up operation with one invalid extra field
        let username = "test9@example.com"
        let password = "ValidPass123"
        let extraFields = [
            "firstName": "John",
            "lastName": "D", // Too short
            "phoneNumber": "12345"
        ]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Create validation policies
        var nameValidators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 2),
            StringHasMaxLen(maxLen: 50)
        ]
        let namePolicy = SingleInputPolicy(singleInputValidators: nameValidators)
        
        let phoneValidators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 10),
            StringHasMaxLen(maxLen: 15),
        ]
        let phonePolicy = SingleInputPolicy(singleInputValidators: phoneValidators)
        
        // Chain decorators
        let firstNameDecorator = DecoratorExtraField(
            operation: baseOperation,
            key: "firstName",
            policy: namePolicy
        )
        
        let lastNameDecorator = DecoratorExtraField(
            operation: firstNameDecorator,
            key: "lastName",
            policy: namePolicy
        )
        
        var phoneDecorator = DecoratorExtraField(
            operation: lastNameDecorator,
            key: "phoneNumber",
            policy: phonePolicy
        )
        
        // Act: Execute the fully decorated operation
        let result = await phoneDecorator.execute()
        
        // Assert: Verify validation failure
        XCTAssertFalse(result, "Extra field validation should fail with one invalid field")
        XCTAssertNotNil(phoneDecorator.getError(), "Error should be captured for validation failure")
    }
    
    // MARK: - Combined Decorator Tests (Extra Field + Email + Password)
    
    func testCompleteDecoratorChainSuccess() async throws {
        // Arrange: Set up operation with all decorators
        let username = "test10@example.com"
        let password = "ValidPass123"
        let extraFields = [
            "firstName": "John",
            "lastName": "Doe"
        ]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Create validation policy for names
        var nameValidators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 2),
            StringHasMaxLen(maxLen: 50)
        ]
        var namePolicy = SingleInputPolicy(singleInputValidators: nameValidators)
        
        // Chain all decorators
        let firstNameDecorator = DecoratorExtraField(
            operation: baseOperation,
            key: "firstName",
            policy: namePolicy
        )
        
        let lastNameDecorator = DecoratorExtraField(
            operation: firstNameDecorator,
            key: "lastName",
            policy: namePolicy
        )
        
        let emailDecorator = DecoratorEmail(lastNameDecorator)
        
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var passwordDecorator = DecoratorPassword(emailDecorator, passwordPolicy: passwordPolicy)
        
        // Act: Execute the fully decorated operation
        let result = await passwordDecorator.execute()
        
        // Assert: Verify successful validation of all components
        XCTAssertTrue(result, "Complete decorator chain should succeed with valid inputs")
        XCTAssertNil(passwordDecorator.error, "Error should be nil for successful validation")
    }
    
    func testCompleteDecoratorChainWithExtraFieldFailure() async throws {
        // Arrange: Set up operation with invalid extra field
        let username = "test11@example.com"
        let password = "ValidPass123"
        let extraFields = [
            "firstName": "J", // Too short
            "lastName": "Doe"
        ]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Create validation policy for names
        var nameValidators: [any SingleInputValidator<String>] = [
            StringHasMinLen(minLen: 2),
            StringHasMaxLen(maxLen: 50)
        ]
        var namePolicy = SingleInputPolicy(singleInputValidators: nameValidators)
        
        // Chain all decorators
        let firstNameDecorator = DecoratorExtraField(
            operation: baseOperation,
            key: "firstName",
            policy: namePolicy
        )
        
        let lastNameDecorator = DecoratorExtraField(
            operation: firstNameDecorator,
            key: "lastName",
            policy: namePolicy
        )
        
        let emailDecorator = DecoratorEmail(lastNameDecorator)
        
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var passwordDecorator = DecoratorPassword(emailDecorator, passwordPolicy: passwordPolicy)
        
        // Act: Execute the fully decorated operation
        let result = await passwordDecorator.execute()
        
        // Assert: Verify validation failure due to extra field
        XCTAssertFalse(result, "Complete decorator chain should fail with invalid extra field")
        XCTAssertNotNil(passwordDecorator.getError(), "Error should be captured for validation failure")
        
        // Verify it's specifically a string length error
        if let stringError = passwordDecorator.getError() as? StringHasMinLenError {
            XCTAssertEqual(stringError, StringHasMinLenError.providedInputIsSmallerThanMinLen, "Should be minimum length error")
        } else {
            XCTFail("Expected StringHasMinLenError but got \(type(of: passwordDecorator.getError()))")
        }
    }
    
    // MARK: - API Integration Tests
    
    func testExtraFieldsSentToAPI() async throws {
        // Arrange: Set up operation with extra fields
        let username = "api_test@example.com"
        let password = "ValidPass123"
        let extraFields = [
            "firstName": "John",
            "lastName": "Doe",
            "phoneNumber": "1234567890"
        ]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify the operation succeeds (implies extra fields were sent correctly)
        XCTAssertTrue(result, "Sign-up should succeed with extra fields sent to API")
        XCTAssertNil(baseOperation.getError(), "Error should be nil when extra fields are properly sent")
        
        // Verify extra fields are accessible
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "firstName"), "John")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "lastName"), "Doe")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "phoneNumber"), "1234567890")
    }
    
    // MARK: - Edge Cases
    
    func testExtraFieldWithSpecialCharacters() async throws {
        // Arrange: Set up operation with special characters in extra field
        let username = "test12@example.com"
        let password = "ValidPass123"
        let extraFields = ["specialField": "Test@#$%^&*()"]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify handling of special characters
        XCTAssertTrue(result, "Sign-up should handle special characters in extra fields")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "specialField"), "Test@#$%^&*()")
    }
    
    func testExtraFieldWithEmptyValue() async throws {
        // Arrange: Set up operation with empty extra field value
        let username = "test13@example.com"
        let password = "ValidPass123"
        let extraFields = ["emptyField": ""]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify handling of empty field values
        XCTAssertTrue(result, "Sign-up should handle empty extra field values")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "emptyField"), "")
    }
    
    func testExtraFieldWithVeryLongValue() async throws {
        // Arrange: Set up operation with very long extra field value
        let username = "test14@example.com"
        let password = "ValidPass123"
        let longValue = String(repeating: "a", count: 1000)
        let extraFields = ["longField": longValue]
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            extraUserInfo: extraFields,
            networkService: networkService
        )
        
        // Act: Execute the operation
        let result = await baseOperation.execute()
        
        // Assert: Verify handling of long field values
        XCTAssertTrue(result, "Sign-up should handle very long extra field values")
        XCTAssertEqual(baseOperation.getExtraUserInfo(key: "longField"), longValue)
    }
}
