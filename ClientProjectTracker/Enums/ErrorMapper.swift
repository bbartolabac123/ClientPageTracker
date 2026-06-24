//
//  ErrorMapper.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//


import Foundation
import Moya

enum ErrorMapper {

    /// Translates an underlying error (Moya, URL, decoding) or HTTP status into a domain `NetworkError`.
    static func map(
        response: Response? = nil,
        error: Error
    ) -> NetworkError {

        if let moyaError = error as? MoyaError {

            switch moyaError {

            case .underlying(let underlying, _):

                if let urlError =
                    underlying as? URLError {

                    switch urlError.code {

                    case .notConnectedToInternet:
                        return .noInternet

                    case .timedOut:
                        return .timeout

                    case .cancelled:
                        return .cancelled

                    default:
                        return .unknown
                    }
                }

            default:
                break
            }
        }

        if error is DecodingError {
            return .decoding
        }

        if let response {

            switch response.statusCode {

            case 401:
                return .unauthorized

            case 404:
                return .notFound

            case 500...599:
                return .serverError(
                    code: response.statusCode
                )

            default:
                break
            }
        }

        return .custom(
            error.localizedDescription
        )
    }
}
