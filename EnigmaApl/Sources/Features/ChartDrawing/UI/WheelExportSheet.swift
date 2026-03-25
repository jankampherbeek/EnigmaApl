// WheelExportSheet.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import UniformTypeIdentifiers

enum WheelExportFormat: String, CaseIterable {
    case png = "PNG"
    case pdf = "PDF"
}

struct WheelExportSheet<Content: View>: View {
    let wheelView: Content

    @Environment(\.dismiss) private var dismiss
    @State private var format: WheelExportFormat = .png

    /// Zijde in punten voor de renderer. PNG-uitvoer is 2× (Retina).
    private let exportPoints: CGFloat = 1200

    var body: some View {
        VStack(spacing: 20) {
            Text(t(ChartWheelKeys.exportTitle))
                .font(.headline)

            Picker(t(ChartWheelKeys.exportFormat), selection: $format) {
                ForEach(WheelExportFormat.allCases, id: \.self) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)

            HStack(spacing: 12) {
                Button(t(ChartWheelKeys.exportCancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Button(t(ChartWheelKeys.exportSave)) { exportAndSave() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(28)
        .frame(minWidth: 320)
    }

    // MARK: - Export

    @MainActor
    private func exportAndSave() {
        // 1. Render de data voordat de sheet sluit (view is nog in de hierarchy).
        guard let (data, filename, contentType) = renderData() else { return }

        // 2. Sluit de exportsheet.
        dismiss()

        // 3. Wacht tot de sluitanimatie klaar is (~0.4 s), toon dan het
        //    opslagdialoog via Task zodat @MainActor-isolatie bewaard blijft.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            #if os(macOS)
            saveMacOS(data: data, filename: filename, contentType: contentType)
            #else
            shareIOS(data: data, filename: filename)
            #endif
        }
    }

    // MARK: - Render

    @MainActor
    private func renderData() -> (Data, String, UTType)? {
        let sized    = wheelView.frame(width: exportPoints, height: exportPoints)
        let renderer = ImageRenderer(content: sized)

        switch format {
        case .png:
            renderer.scale = 2.0    // 2400 × 2400 px
            #if os(macOS)
            guard let nsImage = renderer.nsImage,
                  let tiff    = nsImage.tiffRepresentation,
                  let rep     = NSBitmapImageRep(data: tiff),
                  let data    = rep.representation(using: .png, properties: [:])
            else { return nil }
            return (data, "chart.png", .png)
            #else
            guard let uiImage = renderer.uiImage,
                  let data    = uiImage.pngData() else { return nil }
            return (data, "chart.png", .png)
            #endif

        case .pdf:
            renderer.scale = 1.0
            guard let cgImage = renderer.cgImage,
                  let data    = makePDF(from: cgImage,
                                        size: CGSize(width: exportPoints, height: exportPoints))
            else { return nil }
            return (data, "chart.pdf", .pdf)
        }
    }

    // MARK: - PDF helper

    private func makePDF(from image: CGImage, size: CGSize) -> Data? {
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data) else { return nil }
        var box  = CGRect(origin: .zero, size: size)
        guard let ctx = CGContext(consumer: consumer, mediaBox: &box, nil) else { return nil }
        ctx.beginPDFPage(nil)
        ctx.draw(image, in: box)
        ctx.endPDFPage()
        ctx.closePDF()
        return data as Data
    }

    // MARK: - Platform save

    #if os(macOS)
    @MainActor
    private func saveMacOS(data: Data, filename: String, contentType: UTType) {
        let panel = NSSavePanel()
        panel.allowedContentTypes  = [contentType]
        panel.nameFieldStringValue = filename
        panel.directoryURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first
        panel.canCreateDirectories = true

        if let window = NSApp.keyWindow {
            panel.beginSheetModal(for: window) { response in
                guard response == .OK, let url = panel.url else { return }
                try? data.write(to: url)
            }
        } else {
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                try? data.write(to: url)
            }
        }
    }
    #else
    @MainActor
    private func shareIOS(data: Data, filename: String) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root  = scene.keyWindow?.rootViewController else { return }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        root.present(activity, animated: true)
    }
    #endif

    // MARK: - i18n

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }
}
