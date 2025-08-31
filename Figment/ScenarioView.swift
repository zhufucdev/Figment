//
//  ScenarioView.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/27.
//

import Foundation
import SwiftUI
internal import UniformTypeIdentifiers

private let miniumImageCountForComparsion = 2

struct ScenarioView: View {
    let value: Scenario
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

    var body: some View {
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
                Task {
                    isLoading = true
                    do {
                        let newLayers = try await loadLayers(items)
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

    private func loadLayers(_ items: [NSItemProvider]) async throws -> [Layer] {
        return try await withThrowingTaskGroup(of: Layer.self) { tg in
            for item in items {
                let defaultName = item.suggestedName
                tg.addTask {
                    try await withCheckedThrowingContinuation { continuation in
                        _ = item.loadDataRepresentation(for: .image) { data, err in
                            if let data = data {
                                continuation.resume(returning: Layer(data: data, id: defaultName ?? UUID().uuidString))
                            } else {
                                continuation.resume(throwing: err!)
                            }
                        }
                    }
                }
            }
            return try await tg.reduce([]) { partialResult, layer in
                partialResult + [layer]
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
    let hi = "iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+kIHwImCXwTAwwAAAH3SURBVHja7dyxCcMwEEBRK6TTQt7MM3gAr6E5pNa7uL60LkIQBwkp3oPrxeGPXBiXiIgFeOthBSAQEAgIBAQCAgGBgEBAICAQQCAgEBAICAQEAgIBgYBAQCAgEEAgIBAQCAgEBAICAYGAQEAggEBAICAQEAgIBAQCAgGBgEBAIIBAQCAgEBAICAQEAgIBgYBAAIGAQEAgIBAQCAgEBAICAYGAQACBgEBAICAQEAgIBAQCAgGBAAIBgYBAmLbv+1JKSc11XQIBBAICuWutpV8txhhfOdMYI32m1ponWCAgEBAICAQEAgIBgVgBCISbbduWiEhNrVUggEBAICAQEAgIhB84zzP19fBxHAIBBAICAYGAQEAg8HeeVjBnXVdLcIMAAgGBgEBAICAQEAgIBAQCAgGBMKP3nv6X1KfpvVuuQEAgIBAQCCAQEAgIBAQCAgGBgEBAICAQEAggEBAICAQEAgIBgYBAQCAgEEAgIBDIKhER1gBuEBAICAQEAgIBgYBAQCAgEEAgIBAQCAgEBAICAYGAQEAgIBBAICAQEAgIBAQCAgGBgEBAIIBAQCAgEBAICAQEAgIBgYBAQCCAQEAgIBAQCAgEBAICAYGAQACBgEBAICAQEAgIBAQCAgGBgEAAgYBAQCAgEBAICAQEAgIBgYBAAIFAxgs4EIscjkm1oAAAAABJRU5ErkJggg=="
    let hello = "iVBORw0KGgoAAAANSUhEUgAAAZAAAADICAYAAADGFbfiAAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+kIHwMKFsnoD2AAAA2vSURBVHja7d1/TJXlw8fxDykoCRoTCPl1hIQ/nLZm4nAuBUqbmm1pmKlN0KyJlYH9otbE2nCMBGcpJhVbLmIUaKPVzCyctGBiE6aVhhC/8QwEIkBAPM8fz2N7np5vBvc5Hg7nvF8bf+l17svr8vA+5+bcN24Wi8UiAABG6Q6WAABAQAAABAQAQEAAAAQEAAACAgAgIAAAAgIAICAAAAICAAABAQAQEAAAAQEAEBAAAAEBAICAAAAICACAgAAACAgAgIAAAEBAAAAEBABAQAAABAQAQEAAACAgAAACAgAgIAAAAgIAICAAABAQAAABAQAQEAAAAQEAEBAAAAgIAICAAAAICACAgAAAQEAAAAQEAEBAAAAEBABAQAAAICAAAAICACAgAAACAgAgIAAAEBAAAAEBABAQAAABAQAQEAAACAgAgIAAAAgIAICAAAAICAAABAQAQEAAAAQEAEBAAAAEBAAAAgIAICAAAAICACAgAAACAgAAAQHsrLq6Wm5ubqP+OnDggEMfCyAgAAACAgAgIC6nuLjY0KkHNzc3VVRU3JY5VVRUGJ5TcXExmwoQEAAACAgAgIAAAAgIAICAAABAQAAABAQAQEAAAAQEAEBAAAAgIAAAAgIAsLuJLAHGi66uLrW0tKi+vl7Nzc1qbm5WXV2dzGazrly5oqamJplMJvn6+spkMik0NFRBQUEymUwKDg5WaGio3N3dWcjbrL+/X83NzWpoaFBDQ8Nf+9TW1iaz2az6+nqZTCb5+/srICBA4eHhCgwMVGho6F975unpyUISEMA6zc3NOnPmjI4fP65Dhw796983m83/+GeRkZFKTEzUQw89pHvvvVceHh4ssI388ccfqqys1KlTp5Sdna2enh7D++Tt7a3k5GQtWbJE8+fP19SpU1lgAgKMjMVi0blz5/Tpp58qMzPTZo976dIlpaamKjU1VYsWLdIbb7yhmJgYXu1aoa2tTcXFxdq9e/ctozAaPT09euuttyRJ/v7+2rVrl1avXq2AgAAW3MHwMxA4lJqaGu3YsUPz5s2zaTz+7ocfftCKFSv0xBNP6Pz58yz8KPX19SkvL0+RkZHavn27zeLxn96pbN++XZGRkfroo4/U19fH4hMQ4P8aHBxUfn6+IiIi9O6779rtuCUlJZo7d64+//xz3bhxg40YgV9//VXr1q3T5s2b//VUla309PRoy5YtWr9+vS5evMgmEBDgv3V3d+u1117Thg0bxmwO8fHxOnz4sCwWCxtyC6WlpVqwYIFKSkrG5PhffPGFoqKidPr0aTaDgMDVtbe3KzExUdnZ2WM+l23btqmwsJBN+QdffvmlYmNj7fau41bvRhYvXqxvvvmGTSEgcFWdnZ3avn27jh496jBzWrdunaqrq9mcvzl16pRWrVrlUHN6+OGHVVFRweYQEPyb6Ohoubm52fwrOjp6TP49Q0ND2rVrl0O+4n/ppZfU39/Pf7r/UVdX53DxuGn9+vVqaWlhkwgIXMknn3xi1x+Wj8aJEyd0/PhxNknStWvX9Oqrr475aat/Ultbq7S0NF2/fp3NIiBwBZcvX1ZiYqKhsd7e3kpPT1dZWZnq6+v1559/anBwUMPDw+rv71d7e7vOnz+v/Px8PfDAA4bnmJ6ermvXrrn8Xn311Vf67LPPDI/39vbWoUOH9NNPP6m9vV39/f0aHh5Wb2+v2traVFZWpt27d1s1x9zcXJWWlvLEGgsW2E1RUZFFktN8FRUVjXoNhoeHLUlJSYaOt3fvXovZbB7xsfr6+iy5ubmG/31lZWUjPlZVVZWhY7z33nujXkN7Hevq1auW8PBww+uXkJBgaW5uHtGxLl68aFm1apXhY0VHR1t6e3v5JmNnvAOBXV24cEEHDx4c9bhjx44pOTlZfn5+Ix7j6empp59+Wnl5eYbm6uqvaktLS1VbW2to7JYtW7R//34FBgaO6O/fvFBwzZo1ho5XXl6u8vJynmCcwoIzKygoGPWYjIwMPfroo3JzczN0zHXr1mnlypWjHrd//36XPY11/fp1wx+t9vf319tvvy1vb+9RjfP19dU777xj1aksruMhIHBSHR0dSk9PH/W4J5980nA8JGny5MnavHnzqMeZzWaX/YRPTU2N4Yv1srKyNGPGDENjZ86cqffff9/wi5OmpiaeaAQEzujcuXOjHrNx40aFhIRYfezZs2cbGtfY2OiSe1VZWWl47NKlS6069vLlyw2Praqq4olGQOCMjFz0tWDBApsc28fHx9C423WTQEdn9N3HCy+8IH9/f6uOHRISoo0bNxoae/bsWZ5oBATO5saNGzp27Jihb0i2uGDS6K3A29raXG6v+vv7dfjwYUNjY2NjbTKHZcuWGRpXXFzMTTEJCJxNR0eHzpw5M+7m3dnZ6XJ71d7ebnhsWFiYTeYwa9YsQ+Oqq6vV1dXFE46A4H8rLy+XxWKx+Ze9Pvp49erVcbnurvj7J6z5Bjyaj1nfijWnwbq7u/mGQUDgTMbrK3lXvCeWNQGZMmWKTebg5eVFQAgIML5fybvidQXWXPtiq18PbM3jDAwM8IQjIHAmPKnHj8HBQcNjJ0yYYJM5WPM41swfBAQOiLulugZbvWOz5sJRrkYnIHAykyZNYhHGCQ8PD8Njh4aGbDKH4eHhMZk/RmciSwBHDkh2drZefPFFFtCOJk+ebHjswMCATX4OYs1pKF6s8A4ETma0N9a76eeff2bx7GzatGmGx9rqwxLWPI418wcBgQOaPn26oXFff/21zU6LYGSM3vZFkq5cuWKTOVhz3dBdd93FJhIQEBCpqalJv/zyCwtoR76+vobHNjQ02GQORm9iOXv2bN6BEBA4Gy8vL23atMnQ2JMnT7KAduTp6amtW7caGvvjjz/aZA5lZWWGxq1du9ZmHyUGAYEDMXqjvZSUFF2+fJkFtKPFixcbGpeRkWHVvbQkqbW1VRkZGYbGzps3j80jIHBGUVFRhsfu2bPHbr8d8MKFC3/9BkRXvX7l/vvvNzz21KlTVh37xIkThsfed999PNEICJxRZGSk4uLiDI398MMPlZaWdlvvTWU2m5WVlaU5c+aopKTEpfdq1qxZWrRokaGxSUlJhn+TY21treFTnWvXrlVwcDBPNAICZzRx4kSrrunIyMjQzp079fvvv9t0Xg0NDTpw4IDuvvtu7dy5k42S5O7urpSUFMMhTktLG/VNDTs7O/Xmm28anvMzzzxj1RXsICBwcHFxcVadp87JyVFYWJg++OAD1dXVGb5tRXd3t06fPq3k5GSZTCY999xzbM7fxMbGGn5Fn5ubq6SkpBH/7Kqurk7PPvus8vPzDR0vKipKCxcuZNPs/aKQJYA9TZkyRZmZmXrwwQetepybnxJav369Vq5cqZkzZyooKEhTp07VpEmT5OHhoQkTJmhoaEgDAwPq6upSe3u7ampqVF5erqysLDbjX/j4+Gjfvn16/PHHDY3Pz89Xfn6+0tPTFRsbq/DwcHl5eWny5MkaHBxUT0+Pamtr9f333ys1NdWquaanp+vOO+9k0wgInF1MTIxefvllZWZmWv1YN79J4fZYsWKFHnvsMR09etTwY7z++uu3dY5bt25VTEwMmzUGOIUF+/+nu+MOpaamavny5SyGg/P09FRmZqbhW9HcbuHh4UpLS9PEibwWJiBwGT4+PsrJyeFz++PAPffco2PHjjnk3AoKChQYGMgmERC4GpPJpOLiYk4/jANxcXEqKipyqDl9++23Vl1bBAICJ4hIYWGhnn/+eRbDwa1evVrHjx8f83n4+/urrKzM6g9igIDACfj5+Wnv3r0qLCyUv78/C+LAli1bpurqai1dunRMjr9mzRqVlZUZvsgRBAROyN3dXfHx8aqqqjJ8HyRbio+PV0lJCTfm+w/mzp2roqIiHTx40G7H9Pb2Vl5eno4cOaKIiAg2gYAA/19AQIBeeeUVtbS0KC8vz67nuOPi4vTxxx/r0qVLKigo0COPPMKVzbf4hr5t2zY1NjZq3759t+1TWsHBwcrJydFvv/2mhIQEm/y2Q9gOn32DQ5oxY4YSEhK0YcMGXbx4UWfPntXJkyd15MgRm35zeuqpp7Rw4ULNmTNHoaGhvOMwsIY7duzQpk2bVFlZqe+++0579uyxOk4pKSlasmSJ5s+f77AfIYbkZjF6LwhgDHR3d6utrU1tbW1qamqS2WxWa2ur6uvr1dnZqY6ODjU1NSk4OFhBQUGaPn26fHx8NG3aNIWGhiooKEgBAQHy9fWVn5+f3N3dWVQb6+3tVVNTkxobG9XQ0KDm5mbV1taqtbVVra2tqqurU0REhPz8/BQUFKSwsDAFBQXJZDIpJCREwcHBvNMgIAAAZ8bPQAAABAQAQEAAAAQEAEBAAAAgIAAAAgIAICAAAAICACAgAAAQEAAAAQEAEBAAAAEBABAQAAAICACAgAAACAgAgIAAAAgIAAAEBABAQAAABAQAQEAAAAQEAAACAgAgIAAAAgIAICAAAAICAAABAQAQEAAAAQEAEBAAAAEBAICAAAAICACAgAAACAgAAAQEAEBAAAAEBABAQAAABAQAAAICACAgAAACAgAgIAAAAgIAAAEBABAQAAABAQAQEAAAAQEAgIAAAAgIAICAAAAICACAgAAAQEAAAAQEAEBAAAAEBABAQAAAICAAAAICACAgAACn8F9HELQqgkmg8wAAAABJRU5ErkJggg=="
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text("With two layers")
                ScenarioView(value: .init(name: "Test Scenario With Two Layers", timestamp: .now, layers: [
                    Layer(data: Data(base64Encoded: hi)!, id: "layer0"),
                    Layer(data: Data(base64Encoded: hello)!, id: "layer1"),
                ]))
            }

            VStack(alignment: .leading) {
                Text("No layers")
                ScenarioView(value: .init(name: "Test Scenario", timestamp: .now))
            }

            VStack(alignment: .leading) {
                Text("With one layer")
                ScenarioView(value: .init(name: "Test Scenario With One Layer", timestamp: .now, layers: [
                    Layer(data: Data(base64Encoded: hi)!, id: "layer0"),
                ]))
            }
        }
        .safeAreaPadding()
    }
}
