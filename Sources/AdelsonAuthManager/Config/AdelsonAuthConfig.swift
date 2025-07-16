//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 07/07/2025.
//

import Foundation

final class AdelsonAuthConfig: Sendable{
    let appName: String
    let baseUrl: String
    let traditionalSignUpConfig: TraditionalSignUpConfig
    
    init(appName: String, baseUrl: String, signUpEndpoint: String){
        self.appName = appName
        self.baseUrl = baseUrl
        self.traditionalSignUpConfig = TraditionalSignUpConfig(baseUrl: baseUrl, signUpEndpoint: signUpEndpoint)
    }
       
}
