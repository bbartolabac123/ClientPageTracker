//
//  ProjectDetailViewModel.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ProjectDetailViewModel {

    enum Field: Hashable {
        case clientName
        case projectName
        case description
        case dueDate
    }

    enum State: Equatable {
        case editing
        case updating
        case deleting
        case updated
        case deleted
        case failed(String)
    }

    // MARK: - Form Fields

    var clientName: String
    var projectName: String
    var projectDescription: String
    var status: Status
    var priority: Priority
    var startDate: Date
    var dueDate: Date

    // MARK: - UI State

    var state: State = .editing

    var isBusy: Bool { state == .updating || state == .deleting }

    var errorMessage: String? {
        if case let .failed(message) = state { return message }
        return nil
    }

    var didUpdate: Bool { state == .updated }
    var didDelete: Bool { state == .deleted }

    // MARK: - Dependencies

    private let projectID: UUID
    private let clientProjectUseCase: ClientProjectsUseCase

    init(
        project: ClientProject,
        clientProjectUseCase: ClientProjectsUseCase
    ) {
        self.projectID = project.id
        self.clientName = project.clientName
        self.projectName = project.projectName
        self.projectDescription = project.description
        self.status = project.status
        self.priority = project.priority
        self.startDate = project.startdate
        self.dueDate = project.dueDate
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

    private var currentProject: ClientProject {
        ClientProject(
            id: projectID,
            clientName: clientName.trimmed,
            projectName: projectName.trimmed,
            description: projectDescription.trimmed,
            status: status,
            priority: priority,
            startdate: startDate,
            dueDate: dueDate
        )
    }

    // MARK: - Actions

    /// Validates and saves the edited project, updating `state` with the result.
    func update() async {
        guard isValid, !isBusy else { return }

        state = .updating

        do {
            try await clientProjectUseCase.update(clientProject: currentProject)
            state = .updated
        } catch let error as NetworkError {
            state = .failed(error.errorDescription ?? NetworkError.unknown.errorDescription ?? "")
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Deletes the project, updating `state` with the result.
    func delete() async {
        guard !isBusy else { return }

        state = .deleting

        do {
            try await clientProjectUseCase.delete(clientProject: currentProject)
            state = .deleted
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
