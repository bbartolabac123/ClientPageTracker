//
//  ClientProjectService.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation
import Moya
internal import Alamofire

enum ClientProjectService {
    case fetchAll
    case save(_ clientProject: ClientProject)
    case update(_ clientProject: ClientProject)
    case delete(_ clientProject: ClientProject)
}

extension ClientProjectService: BaseTargetType {
    
    
    var path: String {
        switch self {
        case .fetchAll, .save:
            return "/api/v1/projects"
        case .update(let clientProject), .delete(let clientProject):
            return "/api/v1/projects/\(clientProject.id.uuidString)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAll:
            return .get
        case .save:
            return .post
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchAll:
            return .requestPlain
        case .save(let clientProject), .update(let clientProject):
            return .requestJSONEncodable(clientProject)
        case .delete:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        switch self {
        case .fetchAll:
            return Data("[]".utf8)
        case .save(let clientProject),
             .update(let clientProject),
             .delete(let clientProject):
            if let data = try? JSONEncoder().encode(clientProject) {
                return data
            }
            return Data()
        }
    }
}
