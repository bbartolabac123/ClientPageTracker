//
//  Moya+.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import Moya

extension MoyaProvider {

    /// Bridges Moya's completion-based request into async/await.
    func asyncRequest(
        _ target: Target
    ) async throws -> Response {

        try await withCheckedThrowingContinuation {
            continuation in

            request(target) {
                result in

                continuation.resume(
                    with: result
                )
            }
        }
    }
}
