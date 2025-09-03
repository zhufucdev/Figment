//
//  Offset.swift
//  Figment
//
//  Created by Steve Reed on 2025/9/3.
//

import Foundation

struct Offset : Codable {
    let x: Double
    let y: Double
    
    static let zero = Offset(x: 0, y: 0)
}
