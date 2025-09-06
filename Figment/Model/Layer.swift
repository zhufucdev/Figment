//
//  Layer.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/31.
//

import Foundation
import SwiftData
internal import CoreGraphics

@Model class Layer {
    var data: Data
    var name: String
    var hidden: Bool
    var offset: Offset
    
    init(data: Data, name: String, hidden: Bool = false, offset: Offset = .zero) {
        self.data = data
        self.name = name
        self.hidden = hidden
        self.offset = offset
    }
}

