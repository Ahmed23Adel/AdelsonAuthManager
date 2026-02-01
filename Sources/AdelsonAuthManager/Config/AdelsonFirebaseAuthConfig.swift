//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 31/01/2026.
//

import Foundation

/// No Storing to token, as it's expected to get it right from firebase
/// something like
/// import FirebaseAuth

/// func getIDToken() async throws -> String {
///    guard let user = Auth.auth().currentUser else {
///        throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
///    }
///    let idToken = try await user.getIDToken(forcibly: false)
///    return idToken
///}
@available(macOS 10.15, *)
public final class AdelsonFirebaseAuthConfig: ObservableObject, Sendable{
    nonisolated(unsafe) public static var shared: AdelsonFirebaseAuthConfig!
    
    let appName: String
    let baseUrl: String
    public let fnFirebaseIdToken: @Sendable () async -> String

    public init(appName: String,
         baseUrl: String,
         fnFirebaseIdToken: @escaping @Sendable () async -> String
    ){
        self.appName = appName
        self.baseUrl = baseUrl
        self.fnFirebaseIdToken = fnFirebaseIdToken
    }
       
}
