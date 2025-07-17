@testable import AdelsonValidator
@testable import AdelsonAuthManager

import XCTest
import Foundation


@available(macOS 13.0.0, *)
class TraditionSignUpWithEmailAndPassValidatorTests: XCTestCase {
    
    // MARK: - Test Setup
    
    var config: AdelsonAuthConfig!
    var networkService: AlamoFireNetworkService!
    
    override func setUp() {
        super.setUp()
        config = AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup", otpEndpoint: "otp", loginEndpoint: "login"
        )
        networkService = AlamoFireNetworkService()
    }
    
    override func tearDown() {
        config = nil
        networkService = nil
        super.tearDown()
    }
    
    // MARK: - Positive Tests
    
    func testSuccessfulSignUp() async throws {
        // Arrange: Set up valid credentials and operation
        let username = "test@example.com"
        let password = "ValidPass123!"
        
        var operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Act: Execute the sign-up operation
        let result = await operation.execute()
        
        // Assert: Verify successful sign-up
        XCTAssertTrue(result, "Sign-up should succeed with valid credentials")
        XCTAssertNil(operation.getError(), "Error should be nil for successful sign-up")
        XCTAssertEqual(operation.getUserName(), username, "Username should match input")
        XCTAssertEqual(operation.getPassword(), password, "Password should match input")
    }
    
    func testDuplicateEmail() async throws {
        // Arrange: Set up valid credentials and operation
        let username = "duplicate@example.com"
        let password = "ValidPass123!"
        
        var operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        let _ = await operation.execute()
        
        // Act: Execute the sign-up operation
        var operation2 = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        let result2 = await operation2.execute()
        
        
        // Assert: Verify successful sign-up
        XCTAssertFalse(result2, "Sign-up should not succeed with duplicate credentials")
        XCTAssertNotNil(operation2.getError(), "Error should not be nil")
        XCTAssertEqual(operation2.getUserName(), username, "Username should match input")
        XCTAssertEqual(operation2.getPassword(), password, "Password should match input")
        if let netError = operation2.getError() as? TraditionslSignUpOperationErrors {
            XCTAssertEqual(netError, TraditionslSignUpOperationErrors.UserNameAlreadyExists,"Error should be Unprocessable Entity")
        } else{
            XCTFail("Expected EmailValidatorError but got \(type(of: operation2.error))")
        }
    }
    
    
    func testSuccessfulSignUpWithWrongEmailDecorator() async throws {
        // Arrange: Set up operation with email validation decorator
        let username = "valid.emailexample.com"
        let password = "ValidPass123!"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        var decoratedOperation = DecoratorEmail(baseOperation)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify successful sign-up with valid email
        XCTAssertFalse(result, "Sign-up should fail with invalid email")
        XCTAssertNotNil(decoratedOperation.error, "Error should be nil for successful validation")
        if let netError = decoratedOperation.getError() as? EmailValidatorError {
            XCTAssertEqual(netError, EmailValidatorError.givenEmailNotValid,"Error should be Unprocessable Entity")
        } else{
            XCTFail("Expected EmailValidatorError")
        }
    }
    
    func testSuccessfulSignUpWithEmailDecorator() async throws {
        // Arrange: Set up operation with email validation decorator
        let username = "valid.email@example.com"
        let password = "ValidPass123!"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        var decoratedOperation = DecoratorEmail(baseOperation)
        
        // Act: Execute the decorated operation
        let result =  await decoratedOperation.execute()
        
        // Assert: Verify successful sign-up with valid email
        XCTAssertTrue(result, "Sign-up should succeed with valid email")
        XCTAssertNil(decoratedOperation.error, "Error should be nil for successful validation")
    }
    
    func testSuccessfulSignUpWithPasswordDecorator() async throws {
        // Arrange: Set up operation with simple password policy
        let username = "test1123@example.com"
        let password = "ValidPass123"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Fix: Explicitly type the password policy
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result =  await decoratedOperation.execute()
        
        // Assert: Verify successful sign-up with valid password
        XCTAssertTrue(result, "Sign-up should succeed with valid password policy")
        XCTAssertNil(decoratedOperation.getError(), "Error should be nil for successful validation")
    }
    
    func testSuccessfulSignUpWithWrongPasswordDecorator() async throws {
        // Arrange: Set up operation with simple password policy
        let username = "test1123@example.com"
        let password = "aa"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        // Fix: Explicitly type the password policy
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result =  await decoratedOperation.execute()
        
        // Assert: Verify successful sign-up with valid password
        XCTAssertFalse(result, "Sign-up should fail with invalid password policy")
        XCTAssertNotNil(decoratedOperation.getError(), "Error should be nil for successful validation")
        if let netError = decoratedOperation.getError() as? StringHasMinLenError{
            XCTAssertEqual(netError, StringHasMinLenError.providedInputIsSmallerThanMinLen,"there should be an error with the password")
        } else{
            XCTFail("Expected EmailValidatorError")
        }
    }
    
    func testSuccessfulSignUpWithBothDecorators() async throws {
        // Arrange: Set up operation with both email and password decorators
        let username = "test1@example.com"
        let password = "ValidPass123"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let emailDecorator = DecoratorEmail(baseOperation)
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var fullDecorator = DecoratorPassword(emailDecorator, passwordPolicy: passwordPolicy)
        
        // Act: Execute the fully decorated operation
        let result = await fullDecorator.execute()
        
        // Assert: Verify successful sign-up with both validations
        XCTAssertTrue(result, "Sign-up should succeed with both email and password validation")
        XCTAssertNil(emailDecorator.error, "Email decorator error should be nil for successful validation")
        XCTAssertNil(fullDecorator.error, "Password decorator error should be nil for successful validation")
    }
    
    func testSuccessfulSignUpWithBothDecoratorsEmailWrong() async throws {
        // Arrange: Set up operation with both email and password decorators
        let username = "test2example.com"
        let password = "ValidPass123"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let emailDecorator = DecoratorEmail(baseOperation)
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var fullDecorator = DecoratorPassword(emailDecorator, passwordPolicy: passwordPolicy)
        
        // Act: Execute the fully decorated operation
        let result =  await fullDecorator.execute()
        
        // Assert: Verify successful sign-up with both validations
        XCTAssertFalse(result, "Sign-up should fail with both email wrong")
        XCTAssertNotNil(fullDecorator.getError(), "Email decorator error should not be nil for successful validation")
        if let emailError = fullDecorator.getError() as? EmailValidatorError {
            XCTAssertEqual(emailError, EmailValidatorError.givenEmailNotValid, "Should be givenEmailNotValid error")
        } else {
            XCTFail("Expected EmailValidatorError but got \(type(of: fullDecorator.getError()))")
        }
    }
    
    func testSuccessfulSignUpWithBothDecoratorsPassWrong() async throws {
        // Arrange: Set up operation with both email and password decorators
        let username = "test33@example.com"
        let password = "aa"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let emailDecorator = DecoratorEmail(baseOperation)
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var fullDecorator = DecoratorPassword(emailDecorator, passwordPolicy: passwordPolicy)
        
        // Act: Execute the fully decorated operation
        let result =  await fullDecorator.execute()
        
        // Assert: Verify successful sign-up with both validations
        XCTAssertFalse(result, "Sign-up should fail with both email wrong")
        XCTAssertNotNil(fullDecorator.getError(), "Email decorator error should not be nil for successful validation")
        if let netError = fullDecorator.getError() as? StringHasMinLenError{
            XCTAssertEqual(netError, StringHasMinLenError.providedInputIsSmallerThanMinLen,"there should be an error with the password")
        } else{
            XCTFail("Expected EmailValidatorError")
        }
    }
    
    // MARK: - Negative Tests - Email Validation
    
    func testSignUpWithInvalidEmail() async throws {
        // Arrange: Set up operation with invalid email
        let username = "invalid-email"
        let password = "ValidPass123!"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        var decoratedOperation = DecoratorEmail(baseOperation)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with invalid email
        XCTAssertFalse(result, "Sign-up should fail with invalid email format")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for invalid email")
    }
    
    
    func testSignUpWithEmptyEmail() async throws {
        // Arrange: Set up operation with empty email
        let username = ""
        let password = "ValidPass123!"
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        var decoratedOperation = DecoratorEmail(baseOperation)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with empty email
        XCTAssertFalse(result, "Sign-up should fail with empty email")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for empty email")
    }
    
    // MARK: - Negative Tests - Password Validation
    
    func testSignUpWithTooShortPassword() async throws {
        // Arrange: Set up operation with password too short for simple policy
        let username = "test@example.com"
        let password = "abc1" // Less than 6 characters
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with too short password
        XCTAssertFalse(result, "Sign-up should fail with password shorter than 6 characters")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for password too short")
    }
    
    func testSignUpWithTooLongPassword() async throws {
        // Arrange: Set up operation with password too long for simple policy
        let username = "test@example.com"
        let password = String(repeating: "a", count: 51) + "B1" // More than 50 characters
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with too long password
        XCTAssertFalse(result, "Sign-up should fail with password longer than 50 characters")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for password too long")
    }
    
    func testSignUpWithPasswordMissingNumber() async throws {
        // Arrange: Set up operation with password missing number
        let username = "test@example.com"
        let password = "ValidPassword" // No numbers
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with password missing number
        XCTAssertFalse(result, "Sign-up should fail with password missing numbers")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for password missing numbers")
    }
    
    func testSignUpWithPasswordMissingLetter() async throws {
        // Arrange: Set up operation with password missing letters
        let username = "test@example.com"
        let password = "123456789" // No letters
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.simplePasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with password missing letters
        XCTAssertFalse(result, "Sign-up should fail with password missing letters")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for password missing letters")
    }
    
    // MARK: - Medium Password Policy Tests
    
    func testMediumPasswordPolicySuccess() async throws {
        // Arrange: Set up operation with password meeting medium policy
        let username = "test998@example.com"
        let password = "ValidPass123!" // 8+ chars, number, special char, no spaces
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.mediumPasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up succeeds with medium policy
        XCTAssertTrue(result, "Sign-up should succeed with password meeting medium policy")
        XCTAssertNil(decoratedOperation.error, "Error should be nil for successful validation")
    }
    
    func testMediumPasswordPolicyFailsWithSpaces() async throws {
        // Arrange: Set up operation with password containing spaces
        let username = "test554@example.com"
        let password = "Valid Pass123!" // Contains spaces
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.mediumPasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        var result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with spaces in password
        XCTAssertFalse(result, "Sign-up should fail with password containing spaces")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for password containing spaces")
    }
    
    func testMediumPasswordPolicyFailsWithoutSpecialChar() async throws {
        // Arrange: Set up operation with password missing special characters
        let username = "test@example.com"
        let password = "ValidPass123" // No special characters
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.mediumPasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        var result = try await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails without special characters
        XCTAssertFalse(result, "Sign-up should fail with password missing special characters")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for password missing special characters")
    }
    
    // MARK: - Hard Password Policy Tests
    
    func testHardPasswordPolicySuccess() async throws {
        // Arrange: Set up operation with password meeting hard policy
        let username = "test11@example.com"
        let password = "ValidPassword123!" // 12+ chars, 3 numbers, 2 lower, 2 upper, 1 special, no spaces
        
        var baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.hardPasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        var result = try await decoratedOperation.execute()
        
        // Assert: Verify sign-up succeeds with hard policy
        XCTAssertTrue(result, "Sign-up should succeed with password meeting hard policy")
        XCTAssertNil(decoratedOperation.error, "Error should be nil for successful validation")
    }
    
    func testHardPasswordPolicyFailsWithInsufficientNumbers() async throws {
        // Arrange: Set up operation with password having insufficient numbers
        let username = "test12@example.com"
        let password = "ValidPasswordAB!" // Only 2 numbers, needs 3
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.hardPasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result = try await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with insufficient numbers
        XCTAssertFalse(result, "Sign-up should fail with password having insufficient numbers")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for insufficient numbers")
    }
    
    func testHardPasswordPolicyFailsWithInsufficientUppercase() async throws {
        // Arrange: Set up operation with password having insufficient uppercase
        let username = "test13@example.com"
        let password = "validpassword123!" // Only 1 uppercase, needs 2
        
        let baseOperation = TraditionslSignUpOperation<DefaultSignUpResponse>(
            username: username,
            password: password,
            config: config,
            networkService: networkService
        )
        
        let passwordPolicy = PredefinedSingleInputPolicies.hardPasswordPolicy()
        var decoratedOperation = DecoratorPassword(baseOperation, passwordPolicy: passwordPolicy)
        
        // Act: Execute the decorated operation
        let result = await decoratedOperation.execute()
        
        // Assert: Verify sign-up fails with insufficient uppercase
        XCTAssertFalse(result, "Sign-up should fail with password having insufficient uppercase letters")
        XCTAssertNotNil(decoratedOperation.error, "Error should be captured for insufficient uppercase letters")
    }
    
}
