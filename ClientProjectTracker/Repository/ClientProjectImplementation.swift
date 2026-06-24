//
//  ClientProjectImplementation.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import SwiftData
import Foundation

final class ClientProjectImplementation: ClientProjectRepository {

    private let context: ModelContext
    private let networkService: NetworkService
    private let connectivity: ConnectivityMonitoring

    init(
        context: ModelContext,
        networkService: NetworkService,
        connectivity: ConnectivityMonitoring = NetworkMonitor.shared
    ) {
        self.context = context
        self.networkService = networkService
        self.connectivity = connectivity
    }

    /// Returns projects from the API when online (refreshing the cache), or from local storage when offline.
    func fetchClientProjects() async throws -> [ClientProject] {
        // Offline: serve whatever we have cached locally.
        guard connectivity.isConnected else {
            return try loadCachedProjects()
        }

        // Online: fetch from the API and refresh the local cache so the
        // data is available the next time we go offline.
        let remoteProjects: [ClientProject] = try await networkService.request(
            ClientProjectService.fetchAll
        )
        
        try cache(remoteProjects)
        
        if remoteProjects.isEmpty {
            return try loadCachedProjects()
        }
        
        return remoteProjects
    }

    /// Saves a new project via the API when online, then mirrors it locally; persists locally only when offline.
    func save(_ clientProject: ClientProject) async throws {
        // Offline: persist locally only.
        guard connectivity.isConnected else {
            try persist(clientProject)
            return
        }

        // Online: save through the API, then mirror the result locally.
        let savedProject: ClientProject = try await networkService.request(ClientProjectService.save(clientProject))
        try persist(savedProject)
    }

    /// Updates a project via the API when online, then mirrors it locally; updates the local copy only when offline.
    func update(_ clientProject: ClientProject) async throws {
        // Offline: update the local copy only.
        guard connectivity.isConnected else {
            try persist(clientProject)
            return
        }

        // Online: update through the API, then mirror the result locally.
        let updatedProject: ClientProject = try await networkService.request(
            ClientProjectService.update(clientProject)
        )
        try persist(updatedProject)
    }

    /// Deletes a project via the API when online, then removes it locally; removes the local copy only when offline.
    func delete(_ clientProject: ClientProject) async throws {
        // Offline: remove the local copy only.
        guard connectivity.isConnected else {
            try remove(clientProject.id)
            return
        }

        // Online: delete through the API, then remove the local copy.
        let _: ClientProject = try await networkService.request(
            ClientProjectService.delete(clientProject)
        )
        try remove(clientProject.id)
    }
}

// MARK: - Local Store (SwiftData)

private extension ClientProjectImplementation {

    /// Fetches all locally cached projects, sorted by start date.
    func loadCachedProjects() throws -> [ClientProject] {
        do {
            let descriptor = FetchDescriptor<ClientProjectEntity>(
                sortBy: [SortDescriptor(\.startdate)]
            )
            return try context.fetch(descriptor).map { $0.toDomain() }
        } catch {
            // Surface SwiftData failures as NetworkError so the only error
            // type escaping the repository is NetworkError.
            throw ErrorMapper.map(error: error)
        }
    }

    /// Upserts a batch of projects into local storage.
    func cache(_ projects: [ClientProject]) throws {
        for project in projects {
            try persist(project)
        }
    }

    /// Inserts the project locally, or updates the existing record with a matching id.
    func persist(_ project: ClientProject) throws {
        do {
            let id = project.id
            let descriptor = FetchDescriptor<ClientProjectEntity>(
                predicate: #Predicate { $0.id == id }
            )

            if let existing = try context.fetch(descriptor).first {
                existing.update(from: project)
            } else {
                context.insert(ClientProjectEntity(from: project))
            }

            try context.save()
        } catch {
            // Surface SwiftData failures as NetworkError so the only error
            // type escaping the repository is NetworkError.
            throw ErrorMapper.map(error: error)
        }
    }

    /// Deletes the locally stored project with the given id, if present.
    func remove(_ id: UUID) throws {
        do {
            let descriptor = FetchDescriptor<ClientProjectEntity>(
                predicate: #Predicate { $0.id == id }
            )

            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            // Surface SwiftData failures as NetworkError so the only error
            // type escaping the repository is NetworkError.
            throw ErrorMapper.map(error: error)
        }
    }
}
