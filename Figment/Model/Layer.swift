//
//  Layer.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/31.
//

import Foundation

struct Layer : Codable, Identifiable {
    let data: Data
    let id: String
    var hidden: Bool = false
}
