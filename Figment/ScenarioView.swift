//
//  ScenarioView.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/27.
//

import Foundation
import SwiftData
import SwiftUI
internal import UniformTypeIdentifiers

private let miniumImageCountForComparsion = 2

struct ScenarioView: View {
    let value: Scenario
    var dropAdapter: LayerDropAdapter? = nil

    @State private var isDropHovered = false
    @State private var isLoading = false
    @State private var layerLoaderError: Error? = nil

    private var layerLoaderErrorLocalized: AppLocalizedError? {
        if let e = layerLoaderError {
            AppLocalizedError(inner: e)
        } else {
            nil
        }
    }

    private var remainingRequiredImages: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let lacking = miniumImageCountForComparsion - value.layers.count
        return formatter.string(from: lacking as NSNumber)?.capitalized ?? String(lacking)
    }

    private var layerImages: [Drawable] {
        Array(value.orderedLayers.map { layer in
            Drawable.parse(data: layer.data)
        })
    }

    var body: some View {
        if value.layers.count < miniumImageCountForComparsion {
            initialDropView
        } else {
            if #available(macOS 26.0, *) {
                comparisonView
                    .ignoresSafeArea(edges: [.horizontal, .top])
            } else {
                comparisonView
                    .ignoresSafeArea(edges: .top)
            }
        }
    }

    private var initialDropView: some View {
        VStack {
            DashedContainer(dashPhase: -10) {
                ZStack {
                    if isDropHovered {
                        Rectangle()
                            .opacity(0.2)
                    }
                    if value.layers.isEmpty {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(50)
                    } else {
                        ZStack {
                            ForEach(Array(value.layers.enumerated()), id: \.element.id) { index, layer in
                                buildPreview(index: index, layer: layer)
                            }
                        }
                        .padding(25)
                    }
                }
                .frame(width: 200, height: 200)
            }
            .onDrop(of: [.image], isTargeted: $isDropHovered) { items in
                if dropAdapter == nil {
                    return false
                }
                    
                Task {
                    isLoading = true
                    do {
                        let newLayers = try await dropAdapter!.loadLayers(items)
                        withAnimation {
                            value.layers += newLayers
                        }
                    } catch {
                        layerLoaderError = error
                    }
                    isLoading = false
                }
                return true
            }
            .alert(isPresented: Binding(get: {
                layerLoaderError != nil
            }, set: { newValue, _ in
                if !newValue {
                    layerLoaderError = nil
                }
            }), error: layerLoaderErrorLocalized, actions: { _ in
                Button("Close") {
                    layerLoaderError = nil
                }
            }, message: { err in
                Text(err.localizedDescription)
            })
            Spacer()
                .frame(height: 20)
            if value.layers.isEmpty {
                Text("Drop here for comparison")
            } else if value.layers.count < miniumImageCountForComparsion {
                Text("\(remainingRequiredImages) more to start")
            }
        }
    }

    @State private var comparisonViewScale: CGFloat = 1
    @State private var showLayersPanel = false
    @Environment(\.selectedLayers) private var selectedLayers: Binding<Set<Layer>>
    private var selectedLayerIds: Binding<Set<PersistentIdentifier>> {
        Binding {
            Set(selectedLayers.wrappedValue.map { $0.persistentModelID })
        } set: { newValue in
            selectedLayers.wrappedValue = Set(newValue.map { id in value.layers.first { layer in
                layer.persistentModelID == id
            }! })
        }
    }

    private var comparisonView: some View {
        ZoomableScrollView(scale: $comparisonViewScale, maxScale: 10, minScale: 0.1) {
            Ring(contestants: layerImages, offsets: value.layers.map { layer in
                layer.offset
            }, hidden: value.layers.map { $0.hidden }, selectedIndices: Set(value.layers.enumerated().filter { _, layer in
                selectedLayers.wrappedValue.contains(layer)
            }.map { index, _ in
                index
            }))
        }
        .ignoresSafeArea(.all)
        .inspector(isPresented: $showLayersPanel) {
            List(selection: selectedLayerIds) {
                ForEach(Array(value.layers.enumerated().reversed()), id: \.element.id) { index, layer in
                    LayerView(layer: Binding(get: {
                        layer
                    }, set: { newValue in
                        value.layers[index] = newValue
                    }))
                }
                .onMove { fromIndex, toIndex in
                    value.layers.move(fromOffsets: fromIndex, toOffset: toIndex)
                    value.layers.enumerated().forEach { index, layer in
                        layer.priority = index
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showLayersPanel = !showLayersPanel
                } label: {
                    Image(systemName: "square.3.layers.3d.down.right")
                }
            }
        }
    }

    func buildPreview(index: Int, layer: Layer) -> some View {
        let offsetY = CGFloat(-15) * CGFloat(value.layers.count - index - 1) / CGFloat(value.layers.count)
        return buildSafeImage(data: layer.data)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .padding(40)
            .frame(width: 150, height: 150)
            .offset(y: offsetY)
            .shadow(color: .black.opacity(0.3), radius: index > 0 ? 30 : 0)
    }
}

#Preview {
    NavigationSplitView {
        List {
            NavigationLink("drop") {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("No layers")
                            ScenarioView(value: .init(name: "Test Scenario", timestamp: .now))
                        }

                        VStack(alignment: .leading) {
                            Text("With one layer")
                            ScenarioView(value: .init(name: "Test Scenario With One Layer", timestamp: .now, layers: [
                                Layer(data: Data(base64Encoded: base64OfHi)!, name: "layer0"),
                            ]))
                        }
                    }
                    .safeAreaPadding()
                }
            }
            NavigationLink("compare") {
                ScenarioView(value: .init(name: "Test Scenario With Two Layers", timestamp: .now, layers: [
                    Layer(data: Data(base64Encoded: base64OfHi)!, name: "layer0"),
                    Layer(data: Data(base64Encoded: base64OfHello)!, name: "layer1"),
                ]))
            }
        }
    } detail: {
        Text("Select an item to preview")
    }
}
