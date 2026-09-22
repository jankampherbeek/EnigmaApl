// AafImportExportScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ImportExport", bundle: .main, comment: "")
}

private let aafContentType = UTType(filenameExtension: "aaf") ?? .plainText

/// Wraps raw AAF'97 text so it can be handed to SwiftUI's cross-platform .fileExporter(document:) API.
private struct AafExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [aafContentType, .plainText] }

    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

/// AAF'97 (Astrological Exchange Format) import/export screen: exports all
/// charts to a UTF-8 .aaf file, or imports charts from one.
struct AafImportExportScreen: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var model = AafImportExportModel()

    @State private var exportDocument: AafExportDocument?
    @State private var showExporter = false
    @State private var showImporter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(format: t(ImportExportKeys.detailTitle), ImportExportSection.aaf97.rawValue))
                    .font(.title2.weight(.semibold))
                Text(t(ImportExportKeys.aafBody))
                    .foregroundStyle(.secondary)

                Divider()

                HStack(spacing: 12) {
                    Button(t(ImportExportKeys.aafExportButton)) {
                        if let data = model.export() {
                            exportDocument = AafExportDocument(data: data)
                            showExporter = true
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button(t(ImportExportKeys.aafImportButton)) {
                        showImporter = true
                    }
                    .buttonStyle(.bordered)
                }

                if let status = model.statusMessage {
                    Label(status, systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                }
                if let error = model.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear { model.setup(context: modelContext) }
        .fileExporter(
            isPresented: $showExporter,
            document: exportDocument,
            contentType: aafContentType,
            defaultFilename: "enigma-export"
        ) { result in
            if case .failure(let error) = result {
                model.errorMessage = error.localizedDescription
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [aafContentType, .plainText]
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
