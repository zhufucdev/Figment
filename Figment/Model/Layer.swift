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
    @Relationship(inverse: \Scenario.layers) var scenario: Scenario?
    @Attribute(.externalStorage) var data: Data
    var name: String
    var hidden: Bool
    private var _offset: Offset?
    var offset: Offset {
        get {
            _offset ?? .zero
        }
        set {
            _offset = newValue
        }
    }
    
    init(data: Data, name: String, hidden: Bool = false, offset: Offset? = nil) {
        self.data = data
        self.name = name
        self.hidden = hidden
        self._offset = offset
    }
}

