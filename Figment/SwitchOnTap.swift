//
//  SwitchOnTab.swift
//  Figment
//
//  Created by Steve Reed on 2025/9/6.
//

import Foundation
import SwiftUI

struct SwitchOnTap<Default : View, Activated: View>: View {
    var enabled: Bool = true
    @ViewBuilder let defaultContent: () -> Default
    @ViewBuilder let activatedContent: () -> Activated
    
    @State private var activated = false
    
    var body: some View {
        if !activated {
            if enabled {
                defaultContent()
                    .onTapGesture {
                        if enabled {
                            activated = true
                        }
                    }
            } else {
                defaultContent()
            }
        } else {
            activatedContent()
                .onKeyPress(.escape) {
                    activated = false
                    return .handled
                }
        }
    }
}
