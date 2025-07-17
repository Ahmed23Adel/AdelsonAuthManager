//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

actor AuthTokenStore {
    static let shared = AuthTokenStore()

    private var accessTokenValue: String?
    private var refreshTokenValue: String?

    func setAccessToken(_ token: String?) {
        accessTokenValue = token
    }

    func setRefreshToken(_ token: String?) {
        refreshTokenValue = token
    }

    func getAccessToken() -> String? {
        accessTokenValue
    }

    func getRefreshToken() -> String? {
        refreshTokenValue
    }
}
