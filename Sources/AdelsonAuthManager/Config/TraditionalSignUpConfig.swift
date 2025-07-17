//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 11/07/2025.
//

import Foundation

public struct TraditionalSignUpConfig: Sendable{
    let signUpEndpoint: String
    let baseUrl: String

    init(baseUrl: String, signUpEndpoint: String){
        self.baseUrl = baseUrl
        self.signUpEndpoint = signUpEndpoint
        
    }
    var url: String {
        baseUrl + signUpEndpoint
    }
}
