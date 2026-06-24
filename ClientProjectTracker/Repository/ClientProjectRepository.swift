//
//  ClientProjectRepository.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import Foundation

protocol ClientProjectRepository {
    /// Returns all projects, sourced from the API or local cache depending on connectivity.
    func fetchClientProjects() async throws -> [ClientProject]
    /// Creates a new project.
    func save(_ clientProject: ClientProject) async throws
    /// Updates an existing project.
    func update(_ clientProject: ClientProject) async throws
    /// Deletes a project.
    func delete(_ clientProject: ClientProject) async throws
}

