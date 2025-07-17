//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

public class DecoratorMainAuthConfigurator: AdelsonAuthOperationDecorator{
    public var operation: any AdelsonAuthOperation<ResponseBodyModel>
    public var error: (any Error)?
    public var extraUserInfo: [String : String] = [:]
    
    public init(operation: any AdelsonAuthOperation<ResponseBodyModel>) {
        self.operation = operation
    }
    
    public func _execute() async -> Bool {
        if await operation.execute(){
            await AuthTokenStore.shared.setAccessToken(operation.getResult()?.access_token)
            await AuthTokenStore.shared.setRefreshToken(operation.getResult()?.refresh_token)
            return true
        } else{
            return false
        }
        
    }
        
    public func getResult() -> ResponseBodyModel? {
        operation.getResult()
    }
    
    
}
