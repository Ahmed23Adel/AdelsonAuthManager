//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 17/07/2025.
//

import Foundation
import Alamofire

enum OTPError: Error {
    case networkError(AFError, statusCode: Int?)
    case invalidURL
    case noResponse
    case decodingError(Error)
    case invalidOTP
}
