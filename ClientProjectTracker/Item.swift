//
//  Item.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
