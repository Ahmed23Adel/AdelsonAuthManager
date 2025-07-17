//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public struct MainAuthConfig: Sendable{
    private(set) var accessToken: String?
    private(set) var refresh_token: String?
    
    init(){
        
    }
    mutating func setAccessToken(accessToken: String){
        self.accessToken = accessToken
    }
    
    mutating func setRefreshToken(refreshToken: String){
        self.refresh_token = refreshToken
    }
}


