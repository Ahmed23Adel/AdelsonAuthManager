//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 07/07/2025.
//

import Foundation

final class AdelsonAuthConfig: Sendable{
    let appName: String
    let baseUrl: String
    let traditionalSignUpConfig: TraditionalSignUpConfig
    let keychainConfig: KeychainConfig
    let otpConfig: OTPConfig
    let traditionalLoginConfig: TraditionalLoginConfig
    
    init(appName: String,
         baseUrl: String,
         signUpEndpoint: String,
         otpEndpoint: String,
         loginEndpoint: String
    ){
        self.appName = appName
        self.baseUrl = baseUrl
        self.traditionalSignUpConfig = TraditionalSignUpConfig(baseUrl: baseUrl, signUpEndpoint: signUpEndpoint)
        self.keychainConfig = KeychainConfig()
        self.otpConfig = OTPConfig(baseURL: baseUrl, endpoint: otpEndpoint)
        self.traditionalLoginConfig = TraditionalLoginConfig(baseUrl: baseUrl, logInEndpoint: loginEndpoint)
    }
       
}
