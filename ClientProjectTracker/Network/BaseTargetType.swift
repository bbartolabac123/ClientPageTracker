//
//  BaseTargetType.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//


import Foundation
import Moya

protocol BaseTargetType: TargetType {}

extension BaseTargetType {

    var baseURL: URL {
        URL(string: "https://dev-api.example.com")!
    }

    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
