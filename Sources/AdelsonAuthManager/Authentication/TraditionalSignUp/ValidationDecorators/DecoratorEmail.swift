//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 13/07/2025.
//

import Foundation
import AdelsonValidator


public class DecoratorEmail<T: Codable & Sendable>: AdelsonAuthOperationDecorator{
    public var extraUserInfo: [String : String] = [:]
    public var operation: any AdelsonAuthOperation<T>
    public var error: (any Error)?
    
    public required init(_ operation: any AdelsonAuthOperation<T>) {
        self.operation = operation
    }
    // why can't i make _exec private?
    // Protocols define an interface. If _execute() were private, it would not be visible outside DecoratorEmail, so the compiler cannot guarantee that DecoratorEmail conforms to AdelsonAuthOperationDecorator.
    public func _execute() -> Bool{
        var emailValidator = EmailValidator(input: getUserName())
        if emailValidator.check(){
            return true
        } else {
            error = emailValidator.getError()
            return false
        }
        
    }
       
    public func getResult() -> T? {
        operation.getResult()
    }
    
}
