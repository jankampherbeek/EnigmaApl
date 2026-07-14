// SynastryAspectComparisonView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Synastry", bundle: .main, comment: "")
}

/// Two aspect tables for a synastry comparison: each table lists, for one person's
/// factors, the aspects formed to the other person's factors (aspect glyph + orb).
/// Factors, aspects and orbs follow the active configuration.
struct SynastryAspectComparisonView: View {
    let first: NamedChart
    let second: NamedChart

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private let glyphW: CGFloat = 32
    private let orbW:   CGFloat = 80
    private let minTableWidth: CGFloat = 260
    private let sectionSpacing: CGFloat = 24

    @State private var availableWidth: CGFloat = 0

    private var sideBySide: Bool { availableWidth >= minTableWidth * 2 + sectionSpacing }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            exportButton

            if sideBySide {
                HStack(alignment: .top, spacing: sectionSpacing) {
                    aspectSection(ownerName: first.name, matches: matches)
                        .frame(minWidth: minTableWidth, alignment: .leading)
                    aspectSection(ownerName: second.name, matches: matches.map { $0.reversed })
                        .frame(minWidth: minTableWidth, alignment: .leading)
                }
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    aspectSection(ownerName: first.name, matches: matches)
                    Divider()
                    aspectSection(ownerName: second.name, matches: matches.map { $0.reversed })
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { newWidth in
            availableWidth = newWidth
        }
    }

    private var exportButton: some View {
        Button { exportPDF() } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Export to PDF")
    }

    // MARK: - Section

    @ViewBuilder
    private func aspectSection(ownerName: String, matches: [AspectRow], scrollable: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ownerName)
                .font(.title3.weight(.semibold))

            if matches.isEmpty {
                Text(t(SynastryKeys.aspectComparisonNoAspects))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                table(matches: matches.sorted { $0.ownFactor.rawValue < $1.ownFactor.rawValue }, scrollable: scrollable)
            }
        }
    }

    // MARK: - Table

    /// GroupBox is deliberately avoided when `scrollable == false`: it collapses to
    /// the wrong (near-zero) height when snapshotted off-screen by ImageRenderer for
    /// PDF export, silently cutting off every row below the header.
    @ViewBuilder
    private func table(matches: [AspectRow], scrollable: Bool) -> some View {
        if scrollable {
            GroupBox {
                ScrollView(.horizontal, showsIndicators: false) {
                    tableContent(matches: matches)
                }
            }
        } else {
            tableContent(matches: matches)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.15))
                )
        }
    }

    @ViewBuilder
    private func tableContent(matches: [AspectRow]) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(t(SynastryKeys.aspectComparisonColRadix))
                    .frame(width: glyphW, alignment: .center)
                Spacer().frame(width: glyphW)
                Text(t(SynastryKeys.aspectComparisonColPartner))
                    .frame(width: glyphW, alignment: .center)
                Text(t(SynastryKeys.aspectComparisonColOrb))
                    .frame(width: orbW, alignment: .trailing)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            Divider()

            ForEach(Array(matches.enumerated()), id: \.offset) { index, row in
                rowView(row, index: index)
            }
        }
    }

    @ViewBuilder
    private func rowView(_ row: AspectRow, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(row.ownFactor))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(row.ownFactor.localizedName)

            Text(GlyphSelector.getGlyphForAspect(row.aspect))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)

            Text(GlyphSelector.getGlyphForFactor(row.otherFactor))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(row.otherFactor.localizedName)

            Text(orbText(row.orb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Data

    private struct AspectRow {
        let ownFactor: Factors
        let aspect: Aspects
        let otherFactor: Factors
        let orb: Double

        var reversed: AspectRow {
            AspectRow(ownFactor: otherFactor, aspect: aspect, otherFactor: ownFactor, orb: orb)
        }
    }

    private var matches: [AspectRow] {
        guard let config = activeConfigs.first else { return [] }
        let found = SynastryAspectsOrchestrator.calculate(
            chartA: first.chart,
            chartB: second.chart,
            factorConfig: config.factorConfig,
            aspectConfig: config.aspectConfig,
            orbConfig: config.orbConfig
        )
        return found.map { AspectRow(ownFactor: $0.factor1, aspect: $0.aspect, otherFactor: $0.factor2, orb: $0.orb) }
    }

    private func orbText(_ orb: Double) -> String {
        let totalMin = Int(abs(orb) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
    }

    // MARK: - PDF export

    /// Fixed width for the exported page. ImageRenderer needs an explicit width to lay out
    /// against off-screen — without it, GroupBox/ForEach content collapses to zero height.
    private let exportWidth: CGFloat = 620

    /// Both tables laid out side by side at natural size, without the on-screen
    /// horizontal scrolling — used only for the rendered PDF page.
    private var exportContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(t(SynastryKeys.resultsTitleAspectComparison))
                .font(.title2.weight(.semibold))

            HStack(alignment: .top, spacing: sectionSpacing) {
                aspectSection(ownerName: first.name, matches: matches, scrollable: false)
                aspectSection(ownerName: second.name, matches: matches.map { $0.reversed }, scrollable: false)
            }
        }
        .padding(24)
        .frame(width: exportWidth, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.white)
    }

    private func exportPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes  = [.pdf]
        panel.nameFieldStringValue = "Synastry aspects.pdf"
        panel.directoryURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first
        panel.canCreateDirectories = true

        if let window = NSApp.keyWindow {
            panel.beginSheetModal(for: window) { response in
                guard response == .OK, let url = panel.url else { return }
                writePDF(to: url)
            }
        } else {
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                writePDF(to: url)
            }
        }
    }

    private func writePDF(to url: URL) {
        let renderer = ImageRenderer(content: exportContent)
        renderer.render { size, renderContext in
            var mediaBox = CGRect(origin: .zero, size: size)
            guard let consumer = CGDataConsumer(url: url as CFURL),
                  let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)
            else { return }
            pdfContext.beginPDFPage(nil)
            renderContext(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
    }
}
