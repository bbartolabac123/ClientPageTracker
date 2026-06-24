//
//  HomeViewModel.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {

    enum State {
        case loading
        case empty
        case loaded([ClientProject])
        case failed(String)
    }

    private(set) var state: State = .loading

    private let clientProjectRepository: ClientProjectRepository

    init(clientProjectRepository: ClientProjectRepository) {
        self.clientProjectRepository = clientProjectRepository
    }

    func loadProjects() async {
        state = .loading

        do {
            let projects = try await clientProjectRepository.fetchClientProjects()
            state = projects.isEmpty ? .empty : .loaded(projects)
        } catch let error as NetworkError {
            state = .failed(error.errorDescription ?? NetworkError.unknown.errorDescription ?? "")
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
