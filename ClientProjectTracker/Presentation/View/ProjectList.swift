//
//  ProjectList.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import SwiftUI

struct ProjectList: View {
    var projects: [ClientProject]
    var coordinator: Coordinator
    var body: some View {
        List(projects) { project in
            ProjectRow(project: project)
                .onTapGesture {
                    coordinator.push(.projectDetail(project))
                }
                .buttonStyle(.plain)
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    ProjectList(projects: [], coordinator: Coordinator())
}
