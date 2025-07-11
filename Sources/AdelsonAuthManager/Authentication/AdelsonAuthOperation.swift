//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 09/07/2025.
//

import Foundation
protocol AdelsonAuthOperation{
    
    func execute() async throws -> Bool
    func getUserName()-> String
    func getPassword()-> String
    
}
