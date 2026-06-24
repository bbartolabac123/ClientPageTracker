//
//  NetworkService.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import Moya


protocol NetworkService {
    /// Sends the target request and decodes the response into the expected type.
    func request<
        Target: TargetType,
        Response: Decodable
    >(
        _ target: Target
    ) async throws -> Response
}
