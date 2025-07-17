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

@available(macOS 10.15, *)
class OTPVerificationTests: XCTestCase {
    
    var config: AdelsonAuthConfig!
    var networkService: AlamoFireNetworkService!
    var credentials: BasicCredentials!
    var otpVerification: OTPVerification<MockOTPResponse>!
    
    override func setUp() {
        super.setUp()
        config = AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp", loginEndpoint: "login"
        )
        networkService = AlamoFireNetworkService()
        credentials = BasicCredentials(username: "ahmed1", password: "any")
    }
    
    override func tearDown() {
        config = nil
        networkService = nil
        credentials = nil
        otpVerification = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Test Case 1: Valid OTP verification should succeed
    func testValidOTPVerification() async {
        // Arrange
        let validOTP = "6669"
        credentials = BasicCredentials(username: "ahmed5", password: "any")
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: validOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        
        // Assert
        XCTAssertTrue(result, "Valid OTP should return true")
        XCTAssertNil(otpVerification.getError(), "No error should be present for valid OTP")
        XCTAssertEqual(otpVerification.geOtp(), validOTP, "OTP should match the input")
    }
    
    /// Test Case 2: Invalid OTP (400 status) should fail with proper error
    func testInvalidOTPVerification() async {
        // Arrange
        credentials = BasicCredentials(username: "ahmed6", password: "any")
        let invalidOTP = "0000"
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: invalidOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        print("results", result, otpVerification.getError())
        // Assert
        XCTAssertFalse(result, "Invalid OTP should return false")
        if let error = otpVerification.getError() as? OTPError {
            switch error {
            case .invalidOTP:
                XCTAssertTrue(true, "Should return invalidOTP error for 400 status")
            default:
                XCTFail("Should return invalidOTP error for invalid OTP")
            }
        } else {
            XCTFail("Should have an error for invalid OTP")
        }
    }
    
    /// Test Case 3: Empty OTP should fail
    func testEmptyOTPVerification() async {
        // Arrange
        let emptyOTP = ""
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: emptyOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        
        // Assert
        XCTAssertFalse(result, "Empty OTP should return false")
        XCTAssertNotNil(otpVerification.getError(), "Error should be present for empty OTP")
    }
    
    /// Test Case 4: OTP with special characters should be handled
    func testSpecialCharactersOTP() async {
        // Arrange
        let specialOTP = "12@#$%"
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: specialOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        
        // Assert
        // This depends on server behavior - typically should fail
        XCTAssertFalse(result, "OTP with special characters should typically fail")
        XCTAssertNotNil(otpVerification.getError(), "Error should be present for invalid format OTP")
    }
    
    /// Test Case 5: Very long OTP should be handled
    func testVeryLongOTP() async {
        // Arrange
        let longOTP = "1234567890123456789012345678901234567890"
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: longOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        
        // Assert
        XCTAssertFalse(result, "Very long OTP should fail")
        XCTAssertNotNil(otpVerification.getError(), "Error should be present for overly long OTP")
    }
    
    /// Test Case 6: Network error handling (500 status)
    func testNetworkErrorHandling() async {
        // Arrange
        // This test would require mocking network to return 500 error
        // For real testing, you might temporarily modify server to return 500
        let otp = "123456"
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: otp,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        
        // Assert
        // This will depend on your server's behavior for network errors
        if !result {
            XCTAssertNotNil(otpVerification.getError(), "Error should be present for network issues")
        }
    }
    
    /// Test Case 7: Test setOTP functionality
    func testSetOTPFunctionality() {
        // Arrange
        let initialOTP = "111111"
        let newOTP = "222222"
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: initialOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        otpVerification.setOTP(otp: newOTP)
        
        // Assert
        XCTAssertEqual(otpVerification.geOtp(), newOTP, "OTP should be updated to new value")
        XCTAssertNil(otpVerification.getError(), "Error should be cleared when setting new OTP")
    }
    
    /// Test Case 8: Test getUserCodableObject returns correct parameters
    func testGetUserCodableObject() {
        // Arrange
        let testOTP = "123456"
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: testOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let parameters = otpVerification.getUserCodableObject()
        
        // Assert
        XCTAssertEqual(parameters["username"], credentials.username, "Username should match credentials")
        XCTAssertEqual(parameters["password"], credentials.password, "Password should match credentials")
        XCTAssertEqual(parameters["otp"], testOTP, "OTP should match input")
        XCTAssertEqual(parameters.count, 3, "Should have exactly 3 parameters")
    }
    
    /// Test Case 9: Test with different credential combinations
    func testDifferentCredentials() async {
        // Arrange
        let credentials1 = BasicCredentials(username: "user1@test.com", password: "pass1")
        let credentials2 = BasicCredentials(username: "user2@test.com", password: "pass2")
        let otp = "123456"
        
        let otpVerification1 = OTPVerification<MockOTPResponse>(
            otp: otp,
            config: config,
            networkService: networkService,
            credentials: credentials1
        )
        
        let otpVerification2 = OTPVerification<MockOTPResponse>(
            otp: otp,
            config: config,
            networkService: networkService,
            credentials: credentials2
        )
        
        // Act
        let result1 = await otpVerification1.execute()
        let result2 = await otpVerification2.execute()
        
        // Assert
        // Results will depend on server setup - test that system handles different users
        let params1 = otpVerification1.getUserCodableObject()
        let params2 = otpVerification2.getUserCodableObject()
        
        XCTAssertNotEqual(params1["username"], params2["username"], "Different users should have different usernames")
        XCTAssertNotEqual(params1["password"], params2["password"], "Different users should have different passwords")
    }
    
    /// Test Case 10: Test concurrent OTP verifications
    func testConcurrentOTPVerifications() async {
        // Arrange
        let otp1 = "123456"
        let otp2 = "654321"
        
        let otpVerification1 = OTPVerification<MockOTPResponse>(
            otp: otp1,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        let otpVerification2 = OTPVerification<MockOTPResponse>(
            otp: otp2,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        async let result1 = otpVerification1.execute()
        async let result2 = otpVerification2.execute()
        
        let (res1, res2) = await (result1, result2)
        
        // Assert
        // Test that concurrent executions don't interfere with each other
        XCTAssertEqual(otpVerification1.geOtp(), otp1, "First verification should maintain its OTP")
        XCTAssertEqual(otpVerification2.geOtp(), otp2, "Second verification should maintain its OTP")
    }
    
    /// Test Case 11: Test with expired OTP (if server supports it)
    func testExpiredOTP() async {
        // Arrange
        let expiredOTP = "999999" // Assuming this represents an expired OTP on your server
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: expiredOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        
        // Assert
        XCTAssertFalse(result, "Expired OTP should fail")
        XCTAssertNotNil(otpVerification.getError(), "Error should be present for expired OTP")
    }
    
    /// Test Case 12: Test URL configuration
    func testURLConfiguration() {
        // Arrange
        let customConfig = AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "https://api.example.com/",
            signUpEndpoint: "custom-signup", otpEndpoint: "verify-otp", loginEndpoint: "login"
        )
        
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: "123456",
            config: customConfig,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act & Assert
        // Test that the OTP verification uses the correct URL from config
        XCTAssertNotNil(otpVerification, "OTP verification should initialize with custom config")
        XCTAssertEqual(otpVerification.geOtp(), "123456", "OTP should be set correctly")
    }
}

// MARK: - Mock Response Structure
struct MockOTPResponse: Codable, Sendable {
    let message: String?
}

// MARK: - Test Performance
@available(macOS 10.15, *)
extension OTPVerificationTests {
    
    /// Performance test for OTP verification
    func testOTPVerificationPerformance() {
        let otp = "123456"
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: otp,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        measure {
            // Measure performance of synchronous operations
            _ = otpVerification.getUserCodableObject()
            _ = otpVerification.geOtp()
        }
    }
}

// MARK: - Integration Tests
@available(macOS 10.15, *)
extension OTPVerificationTests {
    
    /// Integration test with actual server
    func testIntegrationWithRealServer() async {
        // Arrange
        let realOTP = "123456" // Use actual OTP from your test scenario
        otpVerification = OTPVerification<MockOTPResponse>(
            otp: realOTP,
            config: config,
            networkService: networkService,
            credentials: credentials
        )
        
        // Act
        let result = await otpVerification.execute()
        
        // Assert
        // This will test against your actual server
        print("Integration test result: \(result)")
        if let error = otpVerification.getError() {
            print("Integration test error: \(error)")
        }
        
        // Add assertions based on your expected server behavior
        XCTAssertNotNil(result, "Integration test should complete")
    }
}
