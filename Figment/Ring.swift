//
//  RingView.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/31.
//

import Foundation
import SwiftUI

struct Ring: View {
    let contestants: [Drawable]
    @Binding var offsets: [CGPoint]

    private var preferredSize: CGSize? {
        var widestImageWidth = 0.0
        var widestImageAspectRatio = -1.0
        
        func updateWith(size: CGSize) {
            if size.width > widestImageWidth {
                widestImageWidth = size.width
                widestImageAspectRatio = size.aspectRatio
            }
        }
        
        for contestant in contestants {
            switch contestant {
            case let .svg(image):
                updateWith(size: image.size)
            case let .bitmap(image):
                updateWith(size: image.size)
            default:
                continue
            }
        }

        if widestImageAspectRatio < 0 {
            return nil
        }
        
        return CGSize(width: widestImageWidth, height: widestImageWidth / widestImageAspectRatio)
    }

    var body: some View {
        Canvas { context, canvasSize in
            context.blendMode = .difference
            for (index, contestant) in contestants.enumerated() {
                if contestant == Drawable.none {
                    continue
                }
                let size = contestant.size ?? .init(width: 50, height: 50)
                let aspectRatio = size.aspectRatio
                let drawingSize = size.width - canvasSize.width > size.height - canvasSize.height ? CGSize(width: canvasSize.width, height: canvasSize.width / aspectRatio) : CGSize(width: canvasSize.height * aspectRatio, height: canvasSize.height)
                let offset = getOffset(index: index)
                let image = buildImageFor(contestant, size: drawingSize)

                context.draw(image, in: CGRect(x: Int((canvasSize.width - drawingSize.width) / 2 + offset.x), y: Int((canvasSize.height - drawingSize.height) / 2 + offset.y), width: Int(drawingSize.width), height: Int(drawingSize.height)))
            }
        }
        .frame(width: preferredSize?.width, height: preferredSize?.height)
    }

    private func buildImageFor(_ drawable: Drawable, size: CGSize) -> Image {
        switch drawable {
        case var .svg(image):
            image.size = size
            return Image(nsImage: image)
        case let .bitmap(image):
            return Image(nsImage: image)
        default:
            fatalError("Unsupported drawable type.")
        }
    }
    
    private func getOffset(index: Int) -> CGPoint {
        if index < offsets.count {
            return offsets[index]
        }
        return .zero
    }
}

fileprivate extension CGSize {
    var aspectRatio: Double {
        return Double(width / height)
    }
}

#Preview {
    VStack {
        Ring(contestants: [
            Drawable.parse(data: Data(base64Encoded: base64OfHello)!),
            Drawable.parse(data: Data(base64Encoded: base64OfHi)!),
        ], offsets: .constant([]))
        Ring(contestants: [
            Drawable.parse(data: Data(base64Encoded: base64OfHello)!),
            Drawable.parse(data: Data(randomSvg.utf8)),
        ], offsets: .constant([]))
    }
}
