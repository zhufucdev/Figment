//
//  AsyncNSItemProvider.swift
//  Figment
//
//  Created by Steve Reed on 2025/9/6.
//

import Foundation
internal import UniformTypeIdentifiers

extension NSItemProvider {
    func loadDataRepresentation(for contentType: UTType) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            _ = loadDataRepresentation(for: contentType) { data, err in
                if err != nil {
                    continuation.resume(throwing: err!)
                } else {
                    continuation.resume(returning: data!)
                }
            }
        }
    }
}
