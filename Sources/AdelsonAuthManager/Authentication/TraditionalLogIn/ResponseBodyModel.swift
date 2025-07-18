//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public struct ResponseBodyModel: Codable & Sendable{
    public let access_token: String
    public let refresh_token: String
    public let token_type: String
}
