//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 10/07/2025.
//

import Foundation
import Alamofire

enum SignUpError: Error {
    case networkError(AFError, statusCode: Int?)
    case invalidURL
    case noResponse
    case decodingError(Error)
}

