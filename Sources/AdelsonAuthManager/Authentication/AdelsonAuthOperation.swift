//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 09/07/2025.
//

import Foundation
protocol AdelsonAuthOperation{
    var error: (any Error)? { get }
    mutating func execute() async -> Bool
    func getUserName()-> String
    func getPassword()-> String
    func getError() -> Error?
}

extension AdelsonAuthOperation{
    func getError() -> (any Error)? {
        return error
    }
}
