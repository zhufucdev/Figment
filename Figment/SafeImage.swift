//
//  SafeImage.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/31.
//

import Foundation
import SwiftUI

func buildSafeImage(data: Data) -> Image {
    if let data = NSImage(data: data) {
        Image(nsImage: data)
    } else {
        Image(systemName: "photo.badge.exclamationmark.fill")
    }
}
