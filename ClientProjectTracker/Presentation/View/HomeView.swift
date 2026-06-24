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
    @State private var isPresentingCreate = false
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let repository = ClientProjectImplementation(
            context: modelContext,
            networkService: NetworkStubServiceImplementation()
        )
        _viewModel = State(
            wrappedValue: HomeViewModel(clientProjectRepository: repository)
        )
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Projects")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresentingCreate = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("New Project")
                    }
                }
                .task { await viewModel.loadProjects() }
                .refreshable { await viewModel.loadProjects() }
                .sheet(isPresented: $isPresentingCreate) {
                    Task { await viewModel.loadProjects() }
                } content: {
                    CreateProjectView(modelContext: modelContext)
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
                isPresentingCreate = true
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
        List(projects) { project in
            ProjectRow(project: project)
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Row

private struct ProjectRow: View {

    let project: ClientProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(project.projectName)
                    .font(.headline)
                Spacer()
                badge(project.priority.rawValue, color: project.priority.color)
            }

            Text(project.clientName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !project.description.isEmpty {
                Text(project.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                badge(project.status.rawValue, color: project.status.color)
                Spacer()
                Label {
                    Text(project.dueDate, format: .dateTime.month().day().year())
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func badge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: .capsule)
            .foregroundStyle(color)
    }
}

// MARK: - UI Mapping

private extension Status {
    var color: Color {
        switch self {
        case .planning: return .gray
        case .inProgress: return .blue
        case .onHold: return .orange
        case .completed: return .green
        }
    }
}

private extension Priority {
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ClientProjectEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return HomeView(modelContext: container.mainContext)
}
