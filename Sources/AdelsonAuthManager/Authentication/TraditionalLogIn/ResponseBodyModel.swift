//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public struct ResponseBodyModel: Codable & Sendable{
    let access_token: String
    let refresh_token: String
    let token_type: String
}
