//
//  ContentView.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Scenario]
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    NavigationLink {
                        ScenarioView(value: item, dropAdapter: .init(modelContainer: modelContext.container))
                    } label: {
                        Text(item.name)
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(item)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Scenario(name: String(localized: "Scenario \(items.count + 1)"), timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Scenario.self, inMemory: true)
}
