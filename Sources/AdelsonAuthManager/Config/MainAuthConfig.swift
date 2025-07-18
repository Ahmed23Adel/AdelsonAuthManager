//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public struct MainAuthConfig: Sendable{
    public var accessToken: String?
    public var refresh_token: String?
    public var username: String?
    public var password: String?
    
    init(){
        
    }
    public mutating func setAccessToken(accessToken: String){
        self.accessToken = accessToken
    }
    
    public mutating func setRefreshToken(refreshToken: String){
        self.refresh_token = refreshToken
    }
    
    public mutating func setUsername(username: String){
        self.username = username
    }
    
    public mutating func setPassword(password: String){
        self.password = password
    }
    
}


