//
//  File.swift
//  AdelsonAuthManager
//
//  Created by ahmed on 10/07/2025.
//

import Foundation
import Alamofire

protocol AdelsonNetworkService: Sendable{
    func request<T: Decodable & Sendable, P: Encodable & Sendable>(
        url: String,
        method: HTTPMethod,
        parameters: P,
        responseType: T.Type
    ) async throws-> T
}
