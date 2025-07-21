//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 13/07/2025.
//

import Foundation
import AdelsonValidator

@available(macOS 13.0.0, *)
public class DecoratorPassword<T: Codable & Sendable>: AdelsonAuthOperationDecorator{
    public var operation: any AdelsonAuthOperation<T>
    var passwordPolicy: any SingleInputPolicyType<String>
    public var error: (any Error)?
    public var extraUserInfo: [String : String] = [:]
    
    public required init(_ operation: any AdelsonAuthOperation<T>, passwordPolicy: any SingleInputPolicyType<String>) {
        self.operation = operation
        self.passwordPolicy = passwordPolicy
    }
    
    public func _execute() -> Bool {
        passwordPolicy.setInput(inputs: [operation.getPassword()])
        if passwordPolicy.check(){
            return true
        } else{
            error = passwordPolicy.getError()
            return false
        }
    }
    
    public func getResult() -> T? {
        operation.getResult()
    }
}
