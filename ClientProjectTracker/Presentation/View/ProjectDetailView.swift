//
//  ProjectDetailView.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {

    @State private var viewModel: ProjectDetailViewModel
    @State private var isConfirmingDelete = false
    @Environment(\.dismiss) private var dismiss

    private let title: String

    init(project: ClientProject, modelContext: ModelContext) {
        self.title = project.projectName
        let repository = ClientProjectImplementation(
            context: modelContext,
            networkService: NetworkStubServiceImplementation()
        )
        _viewModel = State(
            wrappedValue: ProjectDetailViewModel(
                project: project,
                clientProjectUseCase: ClientProjectsUseCase(
                    clientProjectRepository: repository
                )
            )
        )
    }

    var body: some View {
        Form {
            detailsSection
            classificationSection
            scheduleSection
            updateSection
            deleteSection
                .confirmationDialog(
                    "Delete Project?",
                    isPresented: $isConfirmingDelete,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        Task { await viewModel.delete() }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will permanently delete \"\(title)\".")
                }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .disabled(viewModel.isBusy)
        .overlay { loadingOverlay }
        .alert(
            "Something Went Wrong",
            isPresented: errorAlertBinding,
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(viewModel.errorMessage ?? "") }
        )
        .alert(
            "Project Updated",
            isPresented: updatedAlertBinding,
            actions: { Button("OK") {} },
            message: { Text("Your changes have been saved.") }
        )
        .onChange(of: viewModel.didDelete) { _, deleted in
            if deleted { dismiss() }
        }
    }

    // MARK: - Sections

    private var detailsSection: some View {
        Section("Details") {
            VStack(alignment: .leading, spacing: 6) {
                TextField("Client Name", text: $viewModel.clientName)
                    .textInputAutocapitalization(.words)
                validationText(for: .clientName)
            }

            VStack(alignment: .leading, spacing: 6) {
                TextField("Project Name", text: $viewModel.projectName)
                    .textInputAutocapitalization(.words)
                validationText(for: .projectName)
            }

            VStack(alignment: .leading, spacing: 6) {
                TextField(
                    "Description",
                    text: $viewModel.projectDescription,
                    axis: .vertical
                )
                .lineLimit(3...6)
                validationText(for: .description)
            }
        }
    }

    private var classificationSection: some View {
        Section("Classification") {
            Picker("Status", selection: $viewModel.status) {
                ForEach(Status.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }

            Picker("Priority", selection: $viewModel.priority) {
                ForEach(Priority.allCases) { priority in
                    Text(priority.rawValue).tag(priority)
                }
            }
        }
    }

    private var scheduleSection: some View {
        Section("Schedule") {
            DatePicker(
                "Start Date",
                selection: $viewModel.startDate,
                displayedComponents: .date
            )

            VStack(alignment: .leading, spacing: 6) {
                DatePicker(
                    "Due Date",
                    selection: $viewModel.dueDate,
                    displayedComponents: .date
                )
                validationText(for: .dueDate)
            }
        }
    }

    private var updateSection: some View {
        Section {
            Button {
                Task { await viewModel.update() }
            } label: {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isValid || viewModel.isBusy)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                Text("Delete Project")
                    .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isBusy)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isBusy {
            ZStack {
                Color.black.opacity(0.1).ignoresSafeArea()
                ProgressView()
                    .controlSize(.large)
                    .padding(24)
                    .background(.regularMaterial, in: .rect(cornerRadius: 16))
            }
        }
    }

    @ViewBuilder
    private func validationText(for field: ProjectDetailViewModel.Field) -> some View {
        if let message = viewModel.fieldErrors[field] {
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented { viewModel.state = .editing }
            }
        )
    }

    private var updatedAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.didUpdate },
            set: { isPresented in
                if !isPresented { viewModel.state = .editing }
            }
        )
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ClientProjectEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        ProjectDetailView(
            project: ClientProject(
                clientName: "Acme Corp",
                projectName: "Website Redesign",
                description: "Full redesign of the marketing site.",
                status: .inProgress,
                priority: .high,
                startdate: .now,
                dueDate: .now
            ),
            modelContext: container.mainContext
        )
    }
}
