//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 09/07/2025.
//

import Foundation
public protocol AdelsonAuthOperation<T>{
    associatedtype T = Codable & Sendable
    
    var error: (any Error)? { get }
    var extraUserInfo: [String : String] { get }
    mutating func execute() async -> Bool
    func getUserName()-> String
    func getPassword()-> String
    func getExtraUserInfo(key: String) -> String
    func getError() -> Error?
    func getResult() -> T?
}

extension AdelsonAuthOperation{
    public func getError() -> (any Error)? {
        return error
    }
}
