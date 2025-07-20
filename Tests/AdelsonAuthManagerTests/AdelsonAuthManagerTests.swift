import Testing
@testable import AdelsonAuthManager

@Test func example() async throws {
    print("before wakeUp")
    let config = try await AdelsonAuthPredefinedActions.shared.wakeUp(
        appName: "TestApp",
        baseUrl: "http://localhost:8000/",
        signUpEndpoint: "signup",
        otpEndpoint: "verify-otp",
        loginEndpoint: "login",
        refreshTokenEndPoint: "refresh"
    )
}
