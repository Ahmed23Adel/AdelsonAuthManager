//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 13/07/2025.
//

import Foundation
import AdelsonValidator

@available(macOS 13.0.0, *)
class DecoratorPassword: AdelsonAuthOperationDecorator{
    
    var operation: any AdelsonAuthOperation
    var passwordPolicy: any SingleInputPolicyType<String>
    var error: (any Error)?
    
    required init(_ operation: any AdelsonAuthOperation, passwordPolicy: any SingleInputPolicyType<String>) {
        self.operation = operation
        self.passwordPolicy = passwordPolicy
    }
    
    func _execute() -> Bool {
        passwordPolicy.setInput(inputs: [operation.getPassword()])
        if passwordPolicy.check(){
            return true
        } else{
            error = passwordPolicy.getError()
            return false
        }
    }
    
    func getUserName() -> String {
        operation.getUserName()
    }
    
    func getPassword() -> String {
        operation.getPassword()
    }
    
    
}
