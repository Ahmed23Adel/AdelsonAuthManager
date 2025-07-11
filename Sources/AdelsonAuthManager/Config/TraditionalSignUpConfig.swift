//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 11/07/2025.
//

import Foundation

struct TraditionalSignUpConfig{
    let signUpEndpoint: String
    let baseUrl: String

    init(baseUrl: String, signUpEndpoint: String){
        self.baseUrl = baseUrl
        self.signUpEndpoint = signUpEndpoint
        
    }
    var signUpUrl: String {
        baseUrl + signUpEndpoint
    }
}
