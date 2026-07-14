// SynastryMidpointComparisonView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Synastry", bundle: .main, comment: "")
}

/// Two midpoint sections for a synastry comparison, one per selected chart. For each
/// section, the owning person's own factors sit at the midpoint (occupant), while the
/// other person's factor pairs define the midpoint — shown as a tree graph (as in
/// Analysis/Midpoints) and as a matching table. A shared dial-size picker (360°/90°/45°)
/// controls both sections.
struct SynastryMidpointComparisonView: View {
    let first: NamedChart
    let second: NamedChart

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var dialType: MidpointDialType = .dial360

    private let glyphW: CGFloat = 28
    private let posW:   CGFloat = 140
    private let orbW:   CGFloat = 70
    private let exactW: CGFloat = 100

    private func mp(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Midpoints", bundle: .main, comment: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Picker("", selection: $dialType) {
                    Text(mp(MidpointsKeys.dial360)).tag(MidpointDialType.dial360)
                    Text(mp(MidpointsKeys.dial90)).tag(MidpointDialType.dial90)
                    Text(mp(MidpointsKeys.dial45)).tag(MidpointDialType.dial45)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)

                exportButton
            }

            midpointSection(ownerName: first.name, matches: firstMatches)
            Divider()
            midpointSection(ownerName: second.name, matches: secondMatches)
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
    private func midpointSection(ownerName: String, matches: [MidpointMatch], scrollable: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ownerName)
                .font(.title3.weight(.semibold))

            if matches.isEmpty {
                Text(t(SynastryKeys.midpointComparisonNoMatches))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                MidpointTreeCanvas(matches: matches)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                Divider()
                matchesTable(matches: matches, scrollable: scrollable)
            }
        }
    }

    // MARK: - Table

    /// GroupBox is deliberately avoided when `scrollable == false`: it collapses to
    /// the wrong (near-zero) height when snapshotted off-screen by ImageRenderer for
    /// PDF export, silently cutting off every row below the header.
    @ViewBuilder
    private func matchesTable(matches: [MidpointMatch], scrollable: Bool) -> some View {
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
    private func tableContent(matches: [MidpointMatch]) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(t(SynastryKeys.midpointComparisonColPartner1))
                    .frame(width: glyphW, alignment: .center)
                Text(t(SynastryKeys.midpointComparisonColPartner2))
                    .frame(width: glyphW, alignment: .center)
                Text(mp(MidpointsKeys.colMidpoint))
                    .frame(width: posW, alignment: .trailing)
                Text(t(SynastryKeys.midpointComparisonColRadix))
                    .frame(width: glyphW, alignment: .center)
                Text(mp(MidpointsKeys.colOrb))
                    .frame(width: orbW, alignment: .trailing)
                Text(mp(MidpointsKeys.colExactness))
                    .frame(width: exactW, alignment: .trailing)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            Divider()

            ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                matchRow(match, index: index)
            }
        }
    }

    @ViewBuilder
    private func matchRow(_ match: MidpointMatch, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(match.factor1))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.factor1.localizedName)

            Text(GlyphSelector.getGlyphForFactor(match.factor2))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.factor2.localizedName)

            positionText(match.midpointPosition)
                .frame(width: posW, alignment: .trailing)

            Text(GlyphSelector.getGlyphForFactor(match.matchingFactor))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.matchingFactor.localizedName)

            Text(orbText(match.actualOrb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)

            Text("\(exactness(match))%")
                .frame(width: exactW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Data

    private var firstMatches: [MidpointMatch] {
        guard let config = activeConfigs.first else { return [] }
        return SynastryMidpointsOrchestrator.midpoints(
            occupiedBy: first.chart,
            formedBy: second.chart,
            factorConfig: config.factorConfig,
            orbConfig: config.orbConfig,
            dialType: dialType
        )
    }

    private var secondMatches: [MidpointMatch] {
        guard let config = activeConfigs.first else { return [] }
        return SynastryMidpointsOrchestrator.midpoints(
            occupiedBy: second.chart,
            formedBy: first.chart,
            factorConfig: config.factorConfig,
            orbConfig: config.orbConfig,
            dialType: dialType
        )
    }

    // MARK: - Helpers

    @ViewBuilder
    private func positionText(_ longitude: Double) -> some View {
        let (dmsString, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
        if success, let sign {
            Text(positionAttributedString(dms: dmsString, sign: sign))
        } else {
            Text(PositionInDegreesConversion.DoubleToDms(longitude))
        }
    }

    private func positionAttributedString(dms: String, sign: Signs) -> AttributedString {
        var dmsAttr = AttributedString(dms + " ")
        dmsAttr.font = .body
        var glyphAttr = AttributedString(GlyphSelector.getGlyphForSign(sign))
        glyphAttr.font = .custom("EnigmaAstrology3", size: 18)
        return dmsAttr + glyphAttr
    }

    private func orbText(_ orb: Double) -> String {
        let totalMin = Int(abs(orb) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
    }

    private func exactness(_ match: MidpointMatch) -> Int {
        guard match.maxOrb > 0 else { return 100 }
        return max(0, min(100, Int((1.0 - match.actualOrb / match.maxOrb) * 100)))
    }

    // MARK: - PDF export

    /// Fixed width for the exported page. ImageRenderer needs an explicit width to lay out
    /// against off-screen — without it, GroupBox/ForEach content collapses to zero height.
    private let exportWidth: CGFloat = 640

    private var dialLabel: String {
        switch dialType {
        case .dial360: return mp(MidpointsKeys.dial360)
        case .dial90:  return mp(MidpointsKeys.dial90)
        case .dial45:  return mp(MidpointsKeys.dial45)
        }
    }

    private var exportContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(t(SynastryKeys.resultsTitleMidpointComparison))
                    .font(.title2.weight(.semibold))
                Text("(\(dialLabel))")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            midpointSection(ownerName: first.name, matches: firstMatches, scrollable: false)
            midpointSection(ownerName: second.name, matches: secondMatches, scrollable: false)
        }
        .padding(24)
        .frame(width: exportWidth, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.white)
    }

    private func exportPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes  = [.pdf]
        panel.nameFieldStringValue = "Synastry midpoints.pdf"
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
