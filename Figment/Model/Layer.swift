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
    @Attribute(.externalStorage) var data: Data
    var name: String
    var hidden: Bool
    var priority: Int
    private var _offset: Offset?
    var offset: Offset {
        get {
            _offset ?? .zero
        }
        set {
            _offset = newValue
        }
    }
    
    init(data: Data, name: String, hidden: Bool = false, priority: Int = 0, offset: Offset? = nil) {
        self.data = data
        self.name = name
        self.hidden = hidden
        self._offset = offset
        self.priority = priority
    }
}

