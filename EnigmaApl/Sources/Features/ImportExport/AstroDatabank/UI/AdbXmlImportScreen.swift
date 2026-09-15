// AdbXmlImportScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ImportExport", bundle: .main, comment: "")
}

/// Astro.com / Astro-Databank XML import screen (format 160715). Import-only.
struct AdbXmlImportScreen: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var model = AdbXmlImportModel()

    @State private var showImporter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(format: t(ImportExportKeys.detailTitle), ImportExportSection.astroDienst.rawValue))
                    .font(.title2.weight(.semibold))
                Text(t(ImportExportKeys.adbBody))
                    .foregroundStyle(.secondary)

                Divider()

                Button(t(ImportExportKeys.adbImportButton)) {
                    showImporter = true
                }
                .buttonStyle(.borderedProminent)

                if let status = model.statusMessage {
                    Label(status, systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                }
                if let error = model.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
                if !model.warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(t(ImportExportKeys.warningsHeader))
                            .font(.headline)
                        ForEach(Array(model.warnings.enumerated()), id: \.offset) { _, warning in
                            Label(warning, systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                                .font(.callout)
                        }
                    }
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear { model.setup(context: modelContext) }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.xml]
        ) { result in
            switch result {
            case .success(let url):
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                do {
                    model.importData(try Data(contentsOf: url))
                } catch {
                    model.errorMessage = error.localizedDescription
                }
            case .failure(let error):
                model.errorMessage = error.localizedDescription
            }
        }
    }
}
