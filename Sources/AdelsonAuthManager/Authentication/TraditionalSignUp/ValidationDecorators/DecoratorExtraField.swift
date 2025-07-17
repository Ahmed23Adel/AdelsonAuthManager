//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation
import AdelsonValidator

@available(macOS 13.0.0, *)
class DecoratorExtraField<T: Codable & Sendable>: AdelsonAuthOperationDecorator{
    
    var operation: any AdelsonAuthOperation<T>
    var error: (any Error)?
    var extraUserInfo: [String : String] = [:]
    var key: String
    var policy: SingleInputPolicy<String>
    
    init(operation: any AdelsonAuthOperation<T>, key: String, policy: SingleInputPolicy<String> ) {
        self.operation = operation
        self.key = key
        self.policy = policy
    }
    
    func _execute() async -> Bool {
        policy.setInput(inputs: [getExtraUserInfo(key: key)])
        if policy.check(){
            return true
        }else{
            error = policy.getError()
            return false
        }
    }
        
    func getResult() -> T? {
        operation.getResult()
    }
    
    
    
}
