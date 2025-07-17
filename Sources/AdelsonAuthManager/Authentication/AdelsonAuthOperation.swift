//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 09/07/2025.
//

import Foundation
protocol AdelsonAuthOperation{
    var error: (any Error)? { get }
    var extraUserInfo: [String : String] { get }
    mutating func execute() async -> Bool
    func getUserName()-> String
    func getPassword()-> String
    func getExtraUserInfo(key: String) -> String
    func getError() -> Error?
}

extension AdelsonAuthOperation{
    func getError() -> (any Error)? {
        return error
    }
}
