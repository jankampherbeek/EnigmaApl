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

            Section(t(SettingsKeys.sectionLocation)) {
                TextField(t(SettingsKeys.locationNameLabel), text: $model.locationName)
                LabeledContent(t(SettingsKeys.longitudeLabel)) {
                    HStack(spacing: 6) {
                        DMSComponentPicker(symbol: "°", range: 0...180, selection: $model.longitudeDegrees)
                        DMSComponentPicker(symbol: "′", range: 0...59, selection: $model.longitudeMinutes)
                        DMSComponentPicker(symbol: "″", range: 0...59, selection: $model.longitudeSeconds)
                        Picker(t(SettingsKeys.longitudeHemisphere), selection: $model.lonHemi) {
                            ForEach(LongitudeHemisphere.allCases) { hemisphere in
                                Text(LocalizedStringKey(hemisphere.rbKey)).tag(hemisphere)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .fixedSize()
                    }
                }
                LabeledContent(t(SettingsKeys.latitudeLabel)) {
                    HStack(spacing: 6) {
                        DMSComponentPicker(symbol: "°", range: 0...90, selection: $model.latitudeDegrees)
                        DMSComponentPicker(symbol: "′", range: 0...59, selection: $model.latitudeMinutes)
                        DMSComponentPicker(symbol: "″", range: 0...59, selection: $model.latitudeSeconds)
                        Picker(t(SettingsKeys.latitudeHemisphere), selection: $model.latHemi) {
                            ForEach(LatitudeHemisphere.allCases) { hemisphere in
                                Text(LocalizedStringKey(hemisphere.rbKey)).tag(hemisphere)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .fixedSize()
                    }
                }
                if model.hasDefaultLocation {
                    HStack {
                        Spacer()
                        Button(t(SettingsKeys.buttonClear)) { model.clearDefaultLocation() }
                    }
                }
                Text(t(SettingsKeys.locationHelp))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let errorKey = model.locationErrorKey {
                    Text(t(errorKey))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
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
