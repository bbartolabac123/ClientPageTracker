//
//  CoordinatorView.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import SwiftUI
import SwiftData

struct CoordinatorView: View {

    @State private var coordinator = Coordinator()
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(modelContext: modelContext)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .sheet(item: $coordinator.sheet) { modal in
            modalContent(for: modal)
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { modal in
            modalContent(for: modal)
        }
        .environment(coordinator)
    }

    // MARK: - Builders

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case let .projectDetail(project):
            ProjectDetailView(project: project, modelContext: modelContext)
        }
    }

    @ViewBuilder
    private func modalContent(for modal: AppModal) -> some View {
        switch modal {
        case .createProject:
            CreateProjectView(modelContext: modelContext)
        }
    }
}
