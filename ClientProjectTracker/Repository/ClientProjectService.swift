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
}

extension ClientProjectService: BaseTargetType {
    
    
    var path: String {
        switch self {
        case .fetchAll, .save:
            return "/api/v1/projects"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAll:
            return .get
        case .save:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchAll:
            return .requestPlain
        case .save(let clientProject):
            return .requestJSONEncodable(clientProject)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .fetchAll:
            return Data("[]".utf8)
        case .save(let clientProject):
            if let data = try? JSONEncoder().encode(clientProject) {
                return data
            }
            return Data()
        }
    }
}
