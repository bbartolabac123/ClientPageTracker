protocol NetworkServicing {
    func request<
        Target: TargetType,
        Response: Decodable
    >(
        _ target: Target
    ) async throws -> Response
}