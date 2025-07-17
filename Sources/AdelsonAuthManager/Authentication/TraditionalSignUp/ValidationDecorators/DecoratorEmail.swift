//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 13/07/2025.
//

import Foundation
import AdelsonValidator


class DecoratorEmail<T: Codable & Sendable>: AdelsonAuthOperationDecorator{
    var extraUserInfo: [String : String] = [:]
    var operation: any AdelsonAuthOperation<T>
    private(set) var error: (any Error)?
    
    required init(_ operation: any AdelsonAuthOperation<T>) {
        self.operation = operation
    }
    // why can't i make _exec private?
    // Protocols define an interface. If _execute() were private, it would not be visible outside DecoratorEmail, so the compiler cannot guarantee that DecoratorEmail conforms to AdelsonAuthOperationDecorator.
    func _execute() -> Bool{
        var emailValidator = EmailValidator(input: getUserName())
        if emailValidator.check(){
            return true
        } else {
            error = emailValidator.getError()
            return false
        }
        
    }
       
    func getResult() -> T? {
        operation.getResult()
    }
    
}
