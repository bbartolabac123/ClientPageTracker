//
//  CreateProjectView.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import SwiftUI
import SwiftData

struct CreateProjectView: View {

    @State private var viewModel: CreateProjectViewModel
    @Environment(\.dismiss) private var dismiss

    init(modelContext: ModelContext) {
        let repository = ClientProjectImplementation(
            context: modelContext,
            networkService: NetworkServiceImplementation()
        )
        
        _viewModel = State(
            wrappedValue: CreateProjectViewModel(
               clientProjectUseCase: ClientProjectsUseCase(clientProjectRepository: repository)
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                classificationSection
                scheduleSection
                submitSection
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .disabled(viewModel.isSubmitting)
            .overlay { loadingOverlay }
            .alert(
                "Couldn't Save Project",
                isPresented: errorAlertBinding,
                actions: { Button("OK", role: .cancel) {} },
                message: { Text(viewModel.errorMessage ?? "") }
            )
            .alert(
                "Project Created",
                isPresented: successAlertBinding,
                actions: { Button("Done") { dismiss() } },
                message: { Text("Your project has been saved successfully.") }
            )
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

    private var submitSection: some View {
        Section {
            Button {
                Task { await viewModel.submit() }
            } label: {
                Text("Create Project")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.isSubmitting || !viewModel.fieldErrors.isEmpty)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isSubmitting {
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
    private func validationText(for field: CreateProjectViewModel.Field) -> some View {
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

    private var successAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.didCreateProject },
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
    CreateProjectView(modelContext: container.mainContext)
}
