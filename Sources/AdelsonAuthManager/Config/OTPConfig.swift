//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public struct OTPConfig: Sendable{
    private let baseURL: String
    private let endpoint: String
    
    init(baseURL: String, endpoint: String) {
        self.baseURL = baseURL
        self.endpoint = endpoint
    }
    
    var url: String {
        return "\(baseURL)\(endpoint)"
    }
}
