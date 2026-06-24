//
//  ClientProjectRepository.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import Foundation

protocol ClientProjectRepository {
    func fetchClientProjects() async throws -> [ClientProject]
    func save(_ clientProject: ClientProject) async throws
}

