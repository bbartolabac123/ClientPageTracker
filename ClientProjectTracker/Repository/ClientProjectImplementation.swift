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
        return remoteProjects
    }

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
}

// MARK: - Local Store (SwiftData)

private extension ClientProjectImplementation {

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

    func cache(_ projects: [ClientProject]) throws {
        for project in projects {
            try persist(project)
        }
    }

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
}
