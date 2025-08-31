//
//  AppLocalizedError.swift
//  Figment
//
//  Created by Steve Reed on 2025/8/31.
//

import Foundation

struct AppLocalizedError : LocalizedError {
    let inner: any Error
    var errorDescription: String? {
        if inner is LocalizedError {
            return inner.localizedDescription
        }
        return String(describing: inner.self)
    }
}
