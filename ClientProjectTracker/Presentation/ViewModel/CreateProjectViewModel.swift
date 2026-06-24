//
//  CreateProjectViewModel.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class CreateProjectViewModel {

    enum Field: Hashable {
        case clientName
        case projectName
        case description
        case dueDate
    }

    enum State: Equatable {
        case editing
        case submitting
        case failed(String)
        case succeeded
    }

    // MARK: - Form Fields

    var clientName: String = ""
    var projectName: String = ""
    var projectDescription: String = ""
    var status: Status = .planning
    var priority: Priority = .medium
    var startDate: Date = .now
    var dueDate: Date = .now

    // MARK: - UI State

    var state: State = .editing

    var isSubmitting: Bool {
        state == .submitting
    }

    var errorMessage: String? {
        if case let .failed(message) = state { return message }
        return nil
    }

    var didCreateProject: Bool {
        state == .succeeded
    }

    // MARK: - Dependencies

    private let clientProjectUseCase: ClientProjectsUseCase

    init(
        clientProjectUseCase: ClientProjectsUseCase
    ) {
        self.clientProjectUseCase = clientProjectUseCase
    }

    // MARK: - Validation

    var fieldErrors: [Field: String] {
        var errors: [Field: String] = [:]

        if clientName.trimmed.isEmpty {
            errors[.clientName] = "Client name is required."
        }

        if projectName.trimmed.isEmpty {
            errors[.projectName] = "Project name is required."
        }

        if projectDescription.trimmed.isEmpty {
            errors[.description] = "Description is required."
        }

        if dueDate < startDate {
            errors[.dueDate] = "Due date can't be before the start date."
        }

        return errors
    }

    var isValid: Bool {
        fieldErrors.isEmpty
    }

    // MARK: - Actions

    func submit() async {
        guard isValid else { return }

        state = .submitting

        let project = ClientProject(
            clientName: clientName.trimmed,
            projectName: projectName.trimmed,
            description: projectDescription.trimmed,
            status: status,
            priority: priority,
            startdate: startDate,
            dueDate: dueDate
        )

        do {
            try await clientProjectUseCase.save(clientProject: project)
            state = .succeeded
        } catch let error as NetworkError {
            state = .failed(error.errorDescription ?? NetworkError.unknown.errorDescription ?? "")
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
