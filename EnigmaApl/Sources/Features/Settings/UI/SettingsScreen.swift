// SettingsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Settings", bundle: .main, comment: "")
}

/// Content of the macOS Settings window (⌘,).
struct SettingsScreen: View {
    @StateObject private var model = SettingsModel()

    var body: some View {
        Form {
            Section(t(SettingsKeys.sectionFiles)) {
                LabeledContent(t(SettingsKeys.researchFolderLabel)) {
                    VStack(alignment: .trailing, spacing: 6) {
                        pathText(model.researchFolderPath)
                        HStack {
                            if !model.researchFolderPath.isEmpty {
                                Button(t(SettingsKeys.buttonClear)) { model.clearResearchFolder() }
                            }
                            Button(t(SettingsKeys.buttonChoose)) {
                                model.chooseResearchFolder(prompt: t(SettingsKeys.buttonChoose))
                            }
                        }
                    }
                }
                Text(t(SettingsKeys.researchFolderHelp))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let errorKey = model.errorKey {
                    Text(t(errorKey))
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                LabeledContent(t(SettingsKeys.logFileLabel)) {
                    VStack(alignment: .trailing, spacing: 6) {
                        pathText(model.logFilePath)
                        Button(t(SettingsKeys.buttonShowInFinder)) { model.showLogFile() }
                    }
                }
                Text(t(SettingsKeys.logFileHelp))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 560)
        .navigationTitle(t(SettingsKeys.title))
    }

    private func pathText(_ path: String) -> some View {
        Text(path.isEmpty ? t(SettingsKeys.notSet) : path)
            .foregroundStyle(path.isEmpty ? .secondary : .primary)
            .lineLimit(1)
            .truncationMode(.middle)
            .textSelection(.enabled)
            .help(path)
    }
}
