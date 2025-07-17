//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 07/07/2025.
//

import Foundation

public final class AdelsonAuthConfig: Sendable{
    let appName: String
    let baseUrl: String
    public let traditionalSignUpConfig: TraditionalSignUpConfig
    public let keychainConfig: KeychainConfig
    public let otpConfig: OTPConfig
    public let traditionalLoginConfig: TraditionalLoginConfig
    public let mainAuthConfig: MainAuthConfig = MainAuthConfig()
    public let refreshTokenConfig: RefreshTokenConfig
    
    public init(appName: String,
         baseUrl: String,
         signUpEndpoint: String,
         otpEndpoint: String,
         loginEndpoint: String,
         refreshTokenEndPoint: String
    ){
        self.appName = appName
        self.baseUrl = baseUrl
        self.traditionalSignUpConfig = TraditionalSignUpConfig(baseUrl: baseUrl, signUpEndpoint: signUpEndpoint)
        self.keychainConfig = KeychainConfig()
        self.otpConfig = OTPConfig(baseURL: baseUrl, endpoint: otpEndpoint)
        self.traditionalLoginConfig = TraditionalLoginConfig(baseUrl: baseUrl, logInEndpoint: loginEndpoint)
        self.refreshTokenConfig = RefreshTokenConfig(baseUrl: baseUrl, refreshTokenEndPoint: refreshTokenEndPoint)
    }
       
}
