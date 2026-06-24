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

    private let clientProjectUseCase: ClientProjectsUseCase

    init(clientProjectUseCase: ClientProjectsUseCase) {
        self.clientProjectUseCase = clientProjectUseCase
    }

    /// Loads all projects and reflects the outcome in `state` (loading/empty/loaded/failed).
    func loadProjects() async {
        state = .loading

        do {
            let projects = try await clientProjectUseCase.fetchAllClientProject()
            state = projects.isEmpty ? .empty : .loaded(projects)
        } catch let error as NetworkError {
            state = .failed(error.errorDescription ?? NetworkError.unknown.errorDescription ?? "")
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
