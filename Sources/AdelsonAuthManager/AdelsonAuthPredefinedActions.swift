//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 18/07/2025.
//

import Foundation

enum AdelsonAuthPredefinedActionsErrors: Error{
    case tokenNotStored
}

@available(macOS 10.15, *)
public actor AdelsonAuthPredefinedActions{
    public static let shared = AdelsonAuthPredefinedActions()
    
    public func wakeUp(appName: String,
                baseUrl: String,
                signUpEndpoint: String,
                otpEndpoint: String,
                loginEndpoint: String,
                refreshTokenEndPoint: String
    ) async throws  -> AdelsonAuthConfig{
        // 1- Read the access tokens from keychain and store it in in main configurator
        
        
        let config = await AdelsonAuthConfig(
            appName: appName,
            baseUrl: baseUrl,
            signUpEndpoint: signUpEndpoint,
            otpEndpoint: otpEndpoint,
            loginEndpoint: loginEndpoint,
            refreshTokenEndPoint: refreshTokenEndPoint
        )
        KeychainManager.configure(with: config)
        let keychainManager = KeychainManager.shared        
        let keychainConfig = KeychainConfig()
        let accessToken = await keychainManager.read(account: keychainConfig.accessTokenAccount)
        let refreshToken = await keychainManager.read(account: keychainConfig.refreshTokenAccount)
        let username = await keychainManager.read(account: keychainConfig.usernameAccount)
        let password = await keychainManager.read(account: keychainConfig.passwordAccount)
        
        guard let unwrappedAccessToken = accessToken else{
            throw AdelsonAuthPredefinedActionsErrors.tokenNotStored
        }
        guard let unwrappedRefreshToken = refreshToken else{
            throw AdelsonAuthPredefinedActionsErrors.tokenNotStored
        }
        guard let unwrappedUsername = username else{
            throw AdelsonAuthPredefinedActionsErrors.tokenNotStored
        }
        guard let unwrappedPassword = password else{
            throw AdelsonAuthPredefinedActionsErrors.tokenNotStored
        }
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: String(data: unwrappedAccessToken, encoding: .utf8)!)
            config.mainAuthConfig.setRefreshToken(refreshToken: String(data: unwrappedRefreshToken, encoding: .utf8)!)
            
            config.mainAuthConfig.setUsername(username: String(data: unwrappedUsername, encoding: .utf8)!)
            config.mainAuthConfig.setPassword(password: String(data: unwrappedPassword, encoding: .utf8)!)
        }
        return config
    }
}
