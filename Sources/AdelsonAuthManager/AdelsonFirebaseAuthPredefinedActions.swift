//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 31/01/2026.
//

import Foundation


@available(macOS 10.15, *)
public actor AdelsonFirebaseAuthPredefinedActions{
    public static let shared = AdelsonFirebaseAuthPredefinedActions()
    
    public func wakeUp(appName: String,
                       baseUrl: String,
                       fnFirebaseIdToken: @Sendable @escaping () -> String
    ) async -> AdelsonFirebaseAuthConfig {
        let config = await AdelsonFirebaseAuthConfig(
            appName: appName,
            baseUrl: baseUrl,
            fnFirebaseIdToken: fnFirebaseIdToken,
        )
        return config
    }
}
