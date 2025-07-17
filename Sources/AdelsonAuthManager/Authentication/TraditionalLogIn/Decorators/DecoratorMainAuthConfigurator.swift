//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

class DecoratorMainAuthConfigurator: AdelsonAuthOperationDecorator{
    var operation: any AdelsonAuthOperation<ResponseBodyModel>
    private(set) var error: (any Error)?
    private(set) var extraUserInfo: [String : String] = [:]
    
    init(operation: any AdelsonAuthOperation<ResponseBodyModel>) {
        self.operation = operation
    }
    
    func _execute() async -> Bool {
        if await operation.execute(){
            await AuthTokenStore.shared.setAccessToken(operation.getResult()?.access_token)
            await AuthTokenStore.shared.setRefreshToken(operation.getResult()?.refresh_token)
            return true
        } else{
            return false
        }
        
    }
        
    func getResult() -> ResponseBodyModel? {
        operation.getResult()
    }
    
    
}
