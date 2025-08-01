//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation
public struct TraditionalLoginConfig: Sendable{
    let logInEndpoint: String
    let baseUrl: String

    init(baseUrl: String, logInEndpoint: String){
        self.baseUrl = baseUrl
        self.logInEndpoint = logInEndpoint
        
    }
    public var url: String {
        baseUrl + logInEndpoint
    }
}
