//
//  NetworkService.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation
import Moya

final class NetworkServiceImplementation:
    NetworkService {

    /// Performs a live network request and decodes the response, mapping any failure to a `NetworkError`.
    func request<
        Target: TargetType,
        Response: Decodable
    >(
        _ target: Target
    ) async throws -> Response {

        let provider =
            MoyaProvider<Target>()

        do {

            let response =
            try await provider.asyncRequest(target)

            let valid =
                try response
                    .filterSuccessfulStatusCodes()

            do {

                return try JSONDecoder()
                    .decode(
                        Response.self,
                        from: valid.data
                    )

            } catch {

                throw ErrorMapper.map(
                    response: valid,
                    error: error
                )
            }

        } catch {

            throw ErrorMapper.map(
                error: error
            )
        }
    }
}
