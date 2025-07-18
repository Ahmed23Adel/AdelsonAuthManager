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
    private(set) var username: String?
    private(set) var password: String?
    
    init(){
        
    }
    mutating func setAccessToken(accessToken: String){
        self.accessToken = accessToken
    }
    
    mutating func setRefreshToken(refreshToken: String){
        self.refresh_token = refreshToken
    }
    
    mutating func setUsername(username: String){
        self.username = username
    }
    
    mutating func setPassword(password: String){
        self.password = password
    }
    
}


