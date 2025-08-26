//
//  Item.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/26.
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
