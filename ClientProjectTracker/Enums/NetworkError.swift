//
//  NetworkError.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {

    case unauthorized
    case notFound
    case serverError(code: Int)
    case decoding
    case noInternet
    case timeout
    case cancelled
    case custom(String)
    case unknown

    var errorDescription: String? {

        switch self {

        case .unauthorized:
            return "Unauthorized"

        case .notFound:
            return "Resource not found"

        case let .serverError(code):
            return "Server error (\(code))"

        case .decoding:
            return "Unable to process response"

        case .noInternet:
            return "No internet connection"

        case .timeout:
            return "Request timed out"

        case .cancelled:
            return "Request cancelled"

        case let .custom(message):
            return message

        case .unknown:
            return "Something went wrong"
        }
    }
}
