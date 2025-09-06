//
//  Item.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/26.
//

import Foundation
import SwiftData

@Model
final class Scenario {
    var name: String
    var timestamp: Date
    @Relationship(deleteRule: .cascade)
    var layers: [Layer]
    
    init(name: String, timestamp: Date, layers: [Layer] = []) {
        self.name = name
        self.timestamp = timestamp
        self.layers = layers
    }
}
