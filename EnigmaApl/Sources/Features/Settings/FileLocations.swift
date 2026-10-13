// FileLocations.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Machine-specific file locations. Stored in UserDefaults rather than in the (syncable)
/// configuration, because a folder only exists on this Mac.
/// Folders are stored as app-scoped security bookmarks, so the sandbox grants access again
/// in later sessions. Callers wrap file access in `startAccessingSecurityScopedResource()`.
enum FileLocations {

    private static let researchFolderBookmarkKey = "settings.files.researchFolderBookmark"

    /// Default base folder for new research projects, or nil if none is set or the folder
    /// can no longer be resolved.
    static var defaultResearchFolder: URL? {
        guard let data = UserDefaults.standard.data(forKey: researchFolderBookmarkKey) else { return nil }
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: data,
                                 options: .withSecurityScope,
                                 relativeTo: nil,
                                 bookmarkDataIsStale: &isStale) else {
            Logger.log.warning("FileLocations: could not resolve the default research folder bookmark")
            return nil
        }
        if isStale {
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            try? setDefaultResearchFolder(url)
        }
        return url
    }

    /// Stores `url` as the default research folder; nil removes the setting.
    /// The URL must be accessible, e.g. just selected in an open panel.
    static func setDefaultResearchFolder(_ url: URL?) throws {
        guard let url else {
            UserDefaults.standard.removeObject(forKey: researchFolderBookmarkKey)
            return
        }
        let data = try url.bookmarkData(options: .withSecurityScope,
                                        includingResourceValuesForKeys: nil,
                                        relativeTo: nil)
        UserDefaults.standard.set(data, forKey: researchFolderBookmarkKey)
    }
}
