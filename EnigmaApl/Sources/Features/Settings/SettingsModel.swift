// SettingsModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import AppKit
import Combine

/// Model for the settings window: machine-specific file locations.
@MainActor
final class SettingsModel: ObservableObject {
    @Published private(set) var researchFolderPath: String = ""
    @Published private(set) var errorKey: String? = nil

    var logFilePath: String { Logger.logFilePath ?? "" }

    init() {
        researchFolderPath = FileLocations.defaultResearchFolder?.path ?? ""
    }

    /// Lets the user select the default research folder in an open panel.
    func chooseResearchFolder(prompt: String) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = prompt
        panel.directoryURL = FileLocations.defaultResearchFolder
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try FileLocations.setDefaultResearchFolder(url)
            researchFolderPath = url.path
            errorKey = nil
        } catch {
            Logger.log.error("SettingsModel: could not store the default research folder: \(error.localizedDescription)")
            errorKey = SettingsKeys.errorResearchFolder
        }
    }

    func clearResearchFolder() {
        try? FileLocations.setDefaultResearchFolder(nil)
        researchFolderPath = ""
        errorKey = nil
    }

    /// Shows the log file in Finder, or its folder if nothing has been logged yet.
    func showLogFile() {
        guard let url = Logger.logFileURL else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.open(url.deletingLastPathComponent())
        }
    }
}
