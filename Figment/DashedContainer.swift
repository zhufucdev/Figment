//
//  DropContainer.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/27.
//

import Foundation
import SwiftUI

struct DashedContainer<C: View>: View {
    var cornerRadius: CGFloat = 20
    var dashPhase: CGFloat = 0
    @ViewBuilder
    let content: () -> C

    var body: some View {
        content()
            .overlay(
                RoundedRectangle(cornerSize: .init(width: cornerRadius, height: cornerRadius))
                    .strokeBorder(style: .init(lineWidth: 12, dash: [50, 10], dashPhase: dashPhase))
            )
            .clipShape(RoundedRectangle(cornerSize: .init(width: cornerRadius, height: cornerRadius)))
    }
}

#Preview {
    DashedContainer {
        Rectangle()
    }
}
