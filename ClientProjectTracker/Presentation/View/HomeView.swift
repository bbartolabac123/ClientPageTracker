//
//  HomeView.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @State private var viewModel: HomeViewModel
    @Environment(Coordinator.self) private var coordinator

    init(modelContext: ModelContext) {
        let repository = ClientProjectImplementation(
            context: modelContext,
            networkService: NetworkStubServiceImplementation()
        )
        let clientProjectUseCase = ClientProjectsUseCase(clientProjectRepository: repository)
        _viewModel = State(
            wrappedValue: HomeViewModel(clientProjectUseCase: clientProjectUseCase)
        )
    }

    var body: some View {
        content
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        coordinator.presentSheet(.createProject)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("New Project")
                }
            }
            .task { await viewModel.loadProjects() }
            .refreshable { await viewModel.loadProjects() }
            .onChange(of: coordinator.sheet) { _, newValue in
                // Refresh the list once the create sheet is dismissed.
                if newValue == nil {
                    Task { await viewModel.loadProjects() }
                }
            }
            .onChange(of: coordinator.path) { _, newPath in
                // Refresh when returning to the root (e.g. after an
                // update or delete on the detail screen).
                if newPath.isEmpty {
                    Task { await viewModel.loadProjects() }
                }
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading projects…")

        case .empty:
            emptyState

        case let .loaded(projects):
            projectList(projects)

        case let .failed(message):
            errorState(message)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Projects Yet", systemImage: "folder.badge.plus")
        } description: {
            Text("Create your first client project to get started.")
        } actions: {
            Button("New Project") {
                coordinator.presentSheet(.createProject)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func errorState(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Couldn't Load Projects", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                Task { await viewModel.loadProjects() }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func projectList(_ projects: [ClientProject]) -> some View {
        ProjectList(projects: projects, coordinator: coordinator)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ClientProjectEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        HomeView(modelContext: container.mainContext)
    }
    .environment(Coordinator())
}
