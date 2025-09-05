//
//  Layer.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/31.
//

import Foundation
import SwiftData
internal import CoreGraphics

@Model class Layer: Identifiable, Hashable, Equatable {
    var data: Data
    var id: String
    var hidden: Bool
    var offset: Offset
    
    init(data: Data, id: String, hidden: Bool = false, offset: Offset = .zero) {
        self.data = data
        self.id = id
        self.hidden = hidden
        self.offset = offset
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
