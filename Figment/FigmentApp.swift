//
//  FigmentApp.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/26.
//

import SwiftUI
import SwiftData

@main
struct FigmentApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Scenario.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var selectedLayers = Set<Layer>()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .undoRedo) {
                Menu("Move", systemImage: "arrow.up.and.down.and.arrow.left.and.right") {
                    moveCommands
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(\.selectedLayers, $selectedLayers)
    }
    
    private var moveCommands: some View {
        Group {
            Button("Upwards", systemImage: "arrowtriangle.up") {
                for layer in selectedLayers {
                    layer.offset = layer.offset - (0, 1)
                }
            }
            .keyboardShortcut(.upArrow, modifiers: [])
            Button("Leap Upwards") {
                for layer in selectedLayers {
                    layer.offset = layer.offset - (0, 10)
                }
            }
            .keyboardShortcut(.upArrow, modifiers: .shift)
            
            Button("Downwards", systemImage: "arrowtriangle.down") {
                for layer in selectedLayers {
                    layer.offset = layer.offset + (0, 1)
                }
            }
            .keyboardShortcut(.downArrow, modifiers: [])
            Button("Leap Downwards") {
                for layer in selectedLayers {
                    layer.offset = layer.offset + (0, 10)
                }
            }
            .keyboardShortcut(.downArrow, modifiers: .shift)

            Button("Leftwards", systemImage: "arrowtriangle.left") {
                for layer in selectedLayers {
                    layer.offset = layer.offset - (1, 0)
                }
            }
            .keyboardShortcut(.leftArrow, modifiers: [])
            Button("Leap Leftwards") {
                for layer in selectedLayers {
                    layer.offset = layer.offset - (10, 0)
                }
            }
            .keyboardShortcut(.leftArrow, modifiers: .shift)

            Button("Rightwards", systemImage: "arrowtriangle.right") {
                for layer in selectedLayers {
                    layer.offset = layer.offset + (1, 0)
                }
            }
            .keyboardShortcut(.rightArrow, modifiers: [])
            Button("Leap Rightwards") {
                for layer in selectedLayers {
                    layer.offset = layer.offset + (10, 0)
                }
            }
            .keyboardShortcut(.rightArrow, modifiers: .shift)

            Button("Recenter", systemImage: "inset.filled.center.rectangle") {
                for layer in selectedLayers {
                    layer.offset = .zero
                }
            }
            .keyboardShortcut(.delete, modifiers: [])
        }
        .disabled(selectedLayers.isEmpty)
    }
}
