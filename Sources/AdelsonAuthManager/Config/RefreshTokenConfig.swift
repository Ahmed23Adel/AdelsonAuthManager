//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public struct RefreshTokenConfig: Sendable{
    let baseUrl: String
    let refreshTokenEndPoint: String

    init(baseUrl: String, refreshTokenEndPoint: String) {
        self.baseUrl = baseUrl
        self.refreshTokenEndPoint = refreshTokenEndPoint
    }
    
    var url: String {
        "\(baseUrl)\(refreshTokenEndPoint)"
    }
}
