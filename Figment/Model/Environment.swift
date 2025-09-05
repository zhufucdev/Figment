//
//  LayerContainer.swift
//  Figment
//
//  Created by Steve Reed on 2025/9/5.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var selectedLayers: Binding<Set<Layer>> = .constant(Set())
}
