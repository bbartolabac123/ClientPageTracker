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
    
    /// Fetches all client projects.
    func fetchAllClientProject() async throws -> [ClientProject] {
        try await clientProjectRepository.fetchClientProjects()
    }
    
    /// Creates a new client project.
    func save(clientProject: ClientProject) async throws {
        try await clientProjectRepository.save(clientProject)
    }

    /// Updates an existing client project.
    func update(clientProject: ClientProject) async throws {
        try await clientProjectRepository.update(clientProject)
    }

    /// Deletes a client project.
    func delete(clientProject: ClientProject) async throws {
        try await clientProjectRepository.delete(clientProject)
    }
}
