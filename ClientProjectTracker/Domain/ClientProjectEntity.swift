//
//  ClientProjectEntity.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import Foundation
import SwiftData

@Model
final class ClientProjectEntity: Codable {
    var id: UUID
    var clientName: String
    var projectName: String
    var projectDescription: String
    var status: Status
    var priority: Priority
    var startdate: Date
    var dueDate: Date

    init(
        id: UUID = UUID(),
        clientName: String,
        projectName: String,
        projectDescription: String,
        status: Status,
        priority: Priority,
        startdate: Date,
        dueDate: Date
    ) {
        self.id = id
        self.clientName = clientName
        self.projectName = projectName
        self.projectDescription = projectDescription
        self.status = status
        self.priority = priority
        self.startdate = startdate
        self.dueDate = dueDate
    }

    enum CodingKeys: String, CodingKey {
        case id
        case clientName
        case projectName
        case projectDescription = "description"
        case status
        case priority
        case startdate
        case dueDate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        clientName = try container.decode(String.self, forKey: .clientName)
        projectName = try container.decode(String.self, forKey: .projectName)
        projectDescription = try container.decode(String.self, forKey: .projectDescription)
        status = try container.decode(Status.self, forKey: .status)
        priority = try container.decode(Priority.self, forKey: .priority)
        startdate = try container.decode(Date.self, forKey: .startdate)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(clientName, forKey: .clientName)
        try container.encode(projectName, forKey: .projectName)
        try container.encode(projectDescription, forKey: .projectDescription)
        try container.encode(status, forKey: .status)
        try container.encode(priority, forKey: .priority)
        try container.encode(startdate, forKey: .startdate)
        try container.encode(dueDate, forKey: .dueDate)
    }
}

extension ClientProjectEntity {

    convenience init(from project: ClientProject) {
        self.init(
            id: project.id,
            clientName: project.clientName,
            projectName: project.projectName,
            projectDescription: project.description,
            status: project.status,
            priority: project.priority,
            startdate: project.startdate,
            dueDate: project.dueDate
        )
    }

    func update(from project: ClientProject) {
        clientName = project.clientName
        projectName = project.projectName
        projectDescription = project.description
        status = project.status
        priority = project.priority
        startdate = project.startdate
        dueDate = project.dueDate
    }

    func toDomain() -> ClientProject {
        ClientProject(
            id: id,
            clientName: clientName,
            projectName: projectName,
            description: projectDescription,
            status: status,
            priority: priority,
            startdate: startdate,
            dueDate: dueDate
        )
    }
}
