//
//  LayerView.swift
//  Figment
//
//  Created by Steve Reed on 2025/9/2.
//

import Foundation
import SwiftUI

struct LayerView: View {
    @Binding var layer: Layer
    let order: Int
    
    var body: some View {
        HStack {
            buildSafeImage(data: layer.data)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipped()
                .border(.foreground, width: 2)
            Text("\(Image(systemName: "number"))\(order)")
                .lineLimit(1, reservesSpace: false)
                .truncationMode(.tail)
            Spacer()
            Button(action: {
                layer.hidden = !layer.hidden
            }) {
                Image(systemName: layer.hidden ? "eye.slash.fill" : "eye.fill")
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text(layer.hidden ? "Show layer" : "Hide layer"))
        }
    }
}

#Preview {
    @Previewable @State var layer = Layer(data: Data(base64Encoded: base64OfHello)!, id: "hello")
    LayerView(layer: $layer, order: 0)
}
