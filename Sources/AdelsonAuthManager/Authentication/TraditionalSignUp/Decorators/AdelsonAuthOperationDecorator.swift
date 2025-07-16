//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 13/07/2025.
//

import Foundation

protocol AdelsonAuthOperationDecorator: AdelsonAuthOperation{
    var operation: AdelsonAuthOperation { get set }
    var error: Error? { get }
    func _execute() -> Bool
    
}

extension AdelsonAuthOperationDecorator{
    
    mutating func execute() async -> Bool {
        if _execute(){
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

}
