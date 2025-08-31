# AdelsonAuthManager  

A Swift package that simplifies **user authentication** for iOS applications with built-in support for **signup, login, token management, and OTP verification**.  

It integrates seamlessly with [`AdelsonValidator`](https://github.com/Ahmed23Adel/AdelsonValidator) for credential validation and uses [`Alamofire`](https://github.com/Alamofire/Alamofire) for network requests.  

---

## ✨ Features
- 🔑 **Signup & Login** operations with username, email, and password  
- 🔒 **Secure Keychain Storage** for tokens and credentials  
- 📡 **Automatic Token Refresh** & re-authentication handling  
- 🧾 **Extra Fields Support** during signup (e.g., name, phone, DOB)  
- 🔐 **OTP Verification** for multi-factor authentication  
- ✅ **Client-side Validation** with `AdelsonValidator`  
- 🧪 **Comprehensive Unit Tests** to ensure reliability  

---

## 📦 Installation  

### Swift Package Manager  
Add the following dependency to your `Package.swift`:  

```swift
dependencies: [
    .package(url: "https://github.com/Ahmed23Adel/AdelsonAuthManager.git", branch: "main")
]
```

Or in Xcode:

Go to File > Add Packages

Enter repo URL:

```
https://github.com/Ahmed23Adel/AdelsonAuthManager.git
```


# Usage

1. Signup with Username & Password

  ```
import AdelsonAuthManager

let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
    username: "testuser@example.com",
    password: "ValidPass123!",
    config: config,
    networkService: networkService
)

let result = await operation.execute()

if result {
    print("✅ Signup successful for:", operation.getUserName())
} else {
    print("❌ Signup failed:", operation.getError() ?? "Unknown error")
}

```

### 2. Signup with Extra Fields
   ```
let extraFields = [
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "1234567890",
    "dateOfBirth": "1990-01-01"
]

let operation = TraditionslSignUpOperation<DefaultSignUpResponse>(
    username: "john.doe@example.com",
    password: "StrongPass123!",
    config: config,
    extraUserInfo: extraFields,
    networkService: networkService
)

let result = await operation.execute()

```

### 3. OTP Verification
```
let otpVerification = OTPVerification<MockOTPResponse>(
    otp: "6669",
    config: config,
    networkService: networkService,
    credentials: BasicCredentials(username: "john.doe", password: "StrongPass123!")
)

let result = await otpVerification.execute()

if result {
    print("✅ OTP Verified")
} else {
    print("❌ OTP Verification Failed:", otpVerification.getError() ?? "Unknown error")
}
```
  

---

### 4. Traditional Login
```swift
import AdelsonAuthManager

// MARK: - Successful Login
let traditionalLogin = TraditionalLogIn(
    username: "ahmed",
    password: "any",
    config: config,
    networkService: networkService
)

let result = await traditionalLogin.execute()

if result {
    print("✅ Login successful")
    if let response = traditionalLogin.getResult() {
        print("Access Token:", response.access_token)
        print("Refresh Token:", response.refresh_token)
    }
} else {
    print("❌ Login failed")
}

// MARK: - Login with Extra User Info
let extraInfo = [
    "device_id": "test_device_123",
    "app_version": "1.0.0"
]

let loginWithExtraInfo = TraditionalLogIn(
    username: "ahmed",
    password: "any",
    config: config,
    extraUserInfo: extraInfo,
    networkService: networkService
)

let extraResult = await loginWithExtraInfo.execute()

if extraResult {
    print("✅ Login successful with extra user info")
} else {
    print("❌ Login with extra info failed")
}
```

---

### 5. Keychain Manager
`KeychainManager` securely stores authentication tokens and user credentials.  
It is implemented as a **singleton** and must be configured once before use.  

#### Configure KeychainManager
```swift
import AdelsonAuthManager

// Create a config
let config = AdelsonAuthConfig(
    appName: "MyApp",
    clientId: "your_client_id",
    clientSecret: "your_client_secret",
    baseUrl: "https://api.example.com"
)

// Configure the Keychain Manager
KeychainManager.configure(with: config)

// Access shared instance
let keychainManager = KeychainManager.shared
  ```


---

### 6. Token Refresh & Decorators
`AdelsonAuthManager` provides a flexible way to refresh expired tokens.  
The refresh flow can be extended with **decorators** that automatically save tokens into the Keychain or the in-memory `AuthTokenStore`.

#### Basic Token Refresh
```swift
import AdelsonAuthManager

let refreshOperation = TraditionslRefreshToken(
    username: "",  // not required for refresh
    password: "",  // not required for refresh
    config: config,
    networkService: networkService
)

let result = await refreshOperation.execute()

if result {
    print("✅ Token refresh successful")
    if let response = refreshOperation.getResult() {
        print("New Access Token:", response.access_token)
        print("New Refresh Token:", response.refresh_token)
    }
} else {
    print("❌ Token refresh failed:", refreshOperation.error ?? "Unknown error")
}

```


Using Decorators
Decorators allow you to extend refresh behavior without changing the base operation.

DecoratorSaveAuthToken → Saves tokens securely into the Keychain

DecoratorMainAuthConfigurator → Updates the in-memory AuthTokenStore

Example: Keychain Decorator
```swift
let baseOperation = TraditionslRefreshToken(
    username: "", password: "", config: config, networkService: networkService
)

let keychainDecorator = DecoratorSaveAuthToken(
    operation: baseOperation,
    config: config
)

let result = await keychainDecorator._execute()

```
---

### 7. Networking Layer (Alamofire Integration)

`AdelsonAuthManager` uses [Alamofire](https://github.com/Alamofire/Alamofire) under the hood for all network requests.  
Networking is abstracted behind the `AdelsonNetworkService` protocol, making it easy to customize or replace with your own implementation.

#### AdelsonNetworkService Protocol
```swift
public protocol AdelsonNetworkService: Sendable {
    func request<T: Decodable & Sendable, P: Encodable & Sendable>(
        url: String,
        method: HTTPMethod,
        parameters: P,
        responseType: T.Type
    ) async throws -> T
}


Default Implementation: AlamoFireNetworkService

```
@available(macOS 10.15, *)
public final class AlamoFireNetworkService: AdelsonNetworkService {
    
    public init() {}
    
    public func request<T: Decodable & Sendable, P: Encodable & Sendable>(
        url: String,
        method: Alamofire.HTTPMethod,
        parameters: P,
        responseType: T.Type
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoder: JSONParameterEncoder.default
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        continuation.resume(throwing: SignUpError.networkError(error, statusCode: statusCode))
                    } else if error.isSessionTaskError {
                        continuation.resume(throwing: SignUpError.invalidURL)
                    } else if error.isResponseSerializationError {
                        continuation.resume(throwing: SignUpError.decodingError(error))
                    } else {
                        continuation.resume(throwing: SignUpError.networkError(error, statusCode: nil))
                    }
                }
            }
        }
    }
}

```
