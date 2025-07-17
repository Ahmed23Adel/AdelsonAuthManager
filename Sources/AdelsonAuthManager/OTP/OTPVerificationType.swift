//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation

protocol OTPVerificationType {
    var error: (any Error)? { get }
    var otp: String { get }
    
    func execute() async -> Bool
    func getError() -> (any Error)?
    func geOtp() -> String
}
