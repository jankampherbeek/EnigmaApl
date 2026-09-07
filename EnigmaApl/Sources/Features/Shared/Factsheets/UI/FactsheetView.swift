// FactsheetView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import PDFKit

/// Displays a local PDF factsheet from Resources/PDF.
/// The correct language variant is selected automatically based on the device locale.
struct FactsheetView: View {
    /// Base name of the PDF file, e.g. "midpoints". The language suffix and .pdf extension are added automatically.
    let baseName: String

    @Environment(\.dismiss) private var dismiss

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Shared", bundle: .main, comment: "")
    }

    var body: some View {
        NavigationStack {
            Group {
                if let url = resolvedURL() {
                    PDFKitView(url: url)
                } else {
                    Text("PDF not found.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t(SharedKeys.close)) { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 600, minHeight: 700)
        #endif
    }

    private func resolvedURL() -> URL? {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let suffix: String
        switch languageCode {
        case "nl": suffix = "nl"
        case "de": suffix = "ge"
        case "fr": suffix = "fr"
        default:   suffix = "en"
        }
        for sep in ["-", "_"] {
            if let url = Bundle.main.url(forResource: "\(baseName)\(sep)\(suffix)", withExtension: "pdf") {
                return url
            }
        }
        for sep in ["-", "_"] {
            if let url = Bundle.main.url(forResource: "\(baseName)\(sep)en", withExtension: "pdf") {
                return url
            }
        }
        return nil
    }
}

// MARK: - Factsheet button

/// A button that presents the factsheet PDF for `baseName` in a sheet.
/// Usable inline or wrapped in a `ToolbarItem`; `.buttonStyle(...)` applied
/// to this view propagates to the underlying button.
struct FactsheetButton: View {
    let baseName: String

    @State private var showFactsheet = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Shared", bundle: .main, comment: "")
    }

    var body: some View {
        Button { showFactsheet = true } label: {
            Image(systemName: "book.pages")
        }
        .accessibilityLabel(t(SharedKeys.factsheet))
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: baseName)
        }
    }
}

extension View {
    /// Adds a toolbar item with a `FactsheetButton` for `baseName`.
    func factsheetToolbarButton(baseName: String, placement: ToolbarItemPlacement = .automatic) -> some View {
        toolbar {
            ToolbarItem(placement: placement) {
                FactsheetButton(baseName: baseName)
            }
        }
    }
}

// MARK: - PDFKit wrapper

#if os(macOS)
private struct PDFKitView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        makePDFView()
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {}
}
#else
private struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        makePDFView()
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {}
}
#endif

private extension PDFKitView {
    func makePDFView() -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
}
