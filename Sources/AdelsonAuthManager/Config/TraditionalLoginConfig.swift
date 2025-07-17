//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation
struct TraditionalLoginConfig{
    let logInEndpoint: String
    let baseUrl: String

    init(baseUrl: String, logInEndpoint: String){
        self.baseUrl = baseUrl
        self.logInEndpoint = logInEndpoint
        
    }
    var url: String {
        baseUrl + logInEndpoint
    }
}
