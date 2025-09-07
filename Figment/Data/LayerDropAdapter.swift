//
//  LayerDropAdapter.swift
//  Figment
//
//  Created by Steve Reed on 2025/9/6.
//

import Foundation
import SwiftData
internal import UniformTypeIdentifiers

@ModelActor
public actor LayerDropAdapter {
    func createLayer(_ data: Data, defaultName: String? = nil, priority: Int = 0) async -> PersistentIdentifier {
        let model = Layer(data: data, name: defaultName ?? UUID().uuidString, priority: priority)
        modelContext.insert(model)
        return model.persistentModelID
    }

    func loadLayers(_ items: [NSItemProvider]) async throws -> [Layer] {
        let layers: [Layer] = (try await withThrowingTaskGroup(of: PersistentIdentifier.self) { tg in
            for (index, item) in items.enumerated() {
                tg.addTask {
                    let data = try await item.loadDataRepresentation(for: .image)
                    return await self.createLayer(data, defaultName: item.suggestedName, priority: index)
                }
            }
            return try await tg.reduce([]) { partialResult, layer in
                partialResult + [layer]
            }
        }).map { id in
            modelContext.registeredModel(for: id)!
        }
        try modelContext.save()
        return layers
    }
}
