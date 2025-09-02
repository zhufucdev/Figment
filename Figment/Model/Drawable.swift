//
//  Drawable.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/31.
//

import AppKit
import Foundation

enum Drawable: Equatable {
    case bitmap(image: NSImage)
    case svg(image: NSImage)
    case none

    var size: CGSize? {
        switch self {
        case let .bitmap(image):
            image.size
        case let .svg(image):
            image.size
        case .none:
            nil
        }
    }

    static func parse(data: Data) -> Drawable {
        let text = String(data: data, encoding: .ascii)
        if text?.starts(with: "<") == true {
            return .svg(image: NSImage(data: data)!)
        }

        let nsImage = NSImage(data: data)
        guard nsImage != nil else {
            return .none
        }
        return .bitmap(image: nsImage!)
    }
}
