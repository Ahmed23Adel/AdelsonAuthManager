//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation


@available(macOS 10.15, *)
class OTPVerification<T: Codable & Sendable>: OTPVerificationType{
    var error: (any Error)?
    var otp: String
    private let config: AdelsonAuthConfig
    private let networkService: AdelsonNetworkService
    private let credentials: BasicCredentials

    init(otp: String,
         config: AdelsonAuthConfig,
         networkService: AdelsonNetworkService = AlamoFireNetworkService(),
         credentials: BasicCredentials
    ) {
        self.otp = otp
        self.config = config
        self.networkService = networkService
        self.credentials = credentials
    }
    
    func setOTP(otp: String){
        self.otp = otp
        self.error = nil
    }
    
    func execute() async -> Bool {
        do {
            let _ = try await networkService.request(
                url: config.otpConfig.url,
                method: .post,
                parameters: getUserCodableObject(),
                responseType: T.self)
            print("h1")
            return true
        } catch {
            print("h2")
            self.error = handleNetworkError(error as! SignUpError)
            return false
        }
    }
    
    func getUserCodableObject() -> [String: String] {
        ["username": credentials.username,
         "password": credentials.password,
         "otp": otp
        ]
    }
    
    private func handleNetworkError(_ error: SignUpError) -> (any Error)? {
        switch error {
        case .networkError(_, let statusCode):
            if statusCode != nil && statusCode == 400 {
                return OTPError.invalidOTP
            }
        case .invalidURL,
                .noResponse,
                .decodingError:
            return error
            
        }
       return nil
    }
    
    func getError() -> (any Error)? {
        error
    }
    
    func geOtp() -> String {
        otp
    }
    
    
    
}
