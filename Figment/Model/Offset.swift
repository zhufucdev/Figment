//
//  Offset.swift
//  Figment
//
//  Created by Steve Reed on 2025/9/3.
//

import Foundation

struct Offset : Codable, Equatable {
    let x: Double
    let y: Double
    
    static let zero = Offset(x: 0, y: 0)
}

func + (lhs: Offset, rhs: Offset) -> Offset {
    Offset(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func + (lhs: Offset, rhs: (Double, Double)) -> Offset {
    Offset(x: lhs.x + rhs.0, y: lhs.y + rhs.1)
}

func - (lhs: Offset, rhs: Offset) -> Offset {
    Offset(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func - (lhs: Offset, rhs: (Double, Double)) -> Offset {
    Offset(x: lhs.x - rhs.0, y: lhs.y - rhs.1)
}
