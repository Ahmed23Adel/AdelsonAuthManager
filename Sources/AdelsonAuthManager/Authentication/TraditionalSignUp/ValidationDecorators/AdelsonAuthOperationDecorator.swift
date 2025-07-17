//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 13/07/2025.
//

import Foundation

protocol AdelsonAuthOperationDecorator<T>: AdelsonAuthOperation{
    var operation: any AdelsonAuthOperation<T> { get set }
    var error: Error? { get }
    func _execute() async -> Bool
    
}

extension AdelsonAuthOperationDecorator{
    // I execute myself as validator first then i go deepr in the chain to call subsequent validators
    mutating func execute() async -> Bool {
        if await _execute(){
            return await operation.execute()
        } else{
            return false
        }
        
    }
    
    func getError() -> (any Error)? {
        if let unwrappedError = error{
            return unwrappedError
        } else{
            return operation.getError()
        }
    }

    func getUserName() -> String {
        operation.getUserName()
    }
    
    func getPassword() -> String {
        operation.getPassword()
    }
    
    func getExtraUserInfo(key: String) -> String {
        operation.getExtraUserInfo(key: key)
    }
}
