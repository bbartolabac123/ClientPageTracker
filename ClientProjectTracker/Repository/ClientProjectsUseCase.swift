//
//  ClientProjectsUseCase.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import Foundation

final class ClientProjectsUseCase {
    private let clientProjectRepository: ClientProjectRepository
    
    init(clientProjectRepository: ClientProjectRepository) {
        self.clientProjectRepository = clientProjectRepository
    }
    
    func fetchAllClientProject() async throws -> [ClientProject] {
        try await clientProjectRepository.fetchClientProjects()
    }
    
    func save(clientProject: ClientProject) async throws {
        try await clientProjectRepository.save(clientProject)
    }
}
