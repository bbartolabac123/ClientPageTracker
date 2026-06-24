//
//  ClientProject.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import Foundation

enum Status: String, Codable, CaseIterable, Identifiable {
    case planning = "Planning"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"

    var id: String { rawValue }
}

enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }
}

struct ClientProject: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let clientName: String
    let projectName: String
    let description: String
    let status: Status
    let priority: Priority
    let startdate: Date
    let dueDate: Date
}
