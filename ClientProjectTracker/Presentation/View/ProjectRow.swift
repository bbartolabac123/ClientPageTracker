//
//  ProjectRow.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import SwiftUI

struct ProjectRow: View {

    let project: ClientProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(project.projectName)
                    .font(.headline)
                Spacer()
                badge(project.status.rawValue, color: project.status.color)
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

            HStack(spacing: 12) {
                dateLabel(
                    "Start",
                    date: project.startdate,
                    systemImage: "calendar",
                    color: .secondary
                )
                dateLabel(
                    "Due",
                    date: project.dueDate,
                    systemImage: "calendar.badge.clock",
                    color: .orange
                )
            }
        }
        .padding(8)
        .background(Color.white)
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

    private func dateLabel(
        _ title: String,
        date: Date,
        systemImage: String,
        color: Color
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(color)
            Text(title)
                .fontWeight(.semibold)
                .font(.caption2)
            Text(date, format: .dateTime.month().day().year())
                .font(.caption2)
        }
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
    List {
        ProjectRow(
            project: ClientProject(
                clientName: "Acme Corp",
                projectName: "Website Redesign",
                description: "Full redesign of the marketing site.",
                status: .inProgress,
                priority: .high,
                startdate: .now,
                dueDate: .now
            )
        )
    }
    .listStyle(.insetGrouped)
}
