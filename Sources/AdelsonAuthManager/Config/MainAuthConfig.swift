//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

struct MainAuthConfig{
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


