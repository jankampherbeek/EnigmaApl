// PrimDirResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "PrimDir", bundle: .main, comment: "")
}

struct PrimDirResultsScreen: View {
    @EnvironmentObject private var primDirModel: PrimDirModel
    @EnvironmentObject private var chartSession: ChartSession

    @State private var showHelp = false

    private let dateWidth:   CGFloat = 110
    private let glyphWidth:  CGFloat = 36
    private let aspectWidth: CGFloat = 36
    private let orbWidth:    CGFloat = 60

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(PrimDirKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if !primDirModel.methodDescription.isEmpty {
                    Text(primDirModel.methodDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if !primDirModel.period.isEmpty {
                    Text(primDirModel.period)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if !primDirModel.eventTitle.isEmpty {
                    Text("\(primDirModel.eventTitle) • \(primDirModel.eventDateTxt)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if let error = primDirModel.errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.red)
                }

                if !primDirModel.hasResults {
                    Text(primDirModel.isEventMode
                         ? t(PrimDirKeys.noResultsEvent)
                         : t(PrimDirKeys.noResults))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    hitsTable
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(PrimDirKeys.resultsTitle))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(PrimDirKeys.helpResults))
        }
    }

    // MARK: - Hits table

    private var hitsTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                hitsHeader
                Divider()
                ForEach(Array(primDirModel.hits.enumerated()), id: \.offset) { index, hit in
                    hitRow(hit, index: index)
                }
            }
        }
    }

    private var hitsHeader: some View {
        HStack(spacing: 8) {
            Text(t(PrimDirKeys.colDate))
                .frame(width: dateWidth, alignment: .leading)
            Spacer().frame(width: glyphWidth)
            Spacer().frame(width: aspectWidth)
            Spacer().frame(width: glyphWidth)
            if primDirModel.isEventMode {
                Text(t(PrimDirKeys.colOrb))
                    .frame(width: orbWidth, alignment: .trailing)
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func hitRow(_ hit: PrimDirHit, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(hit.dateTxt)
                .frame(width: dateWidth, alignment: .leading)
                .font(.body.monospacedDigit())

            Text(GlyphSelector.getGlyphForFactor(hit.promissor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphWidth, alignment: .center)
                .accessibilityLabel(hit.promissor.localizedName)

            Text(GlyphSelector.getGlyphForAspect(hit.aspect))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: aspectWidth, alignment: .center)

            Text(GlyphSelector.getGlyphForFactor(hit.significator))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphWidth, alignment: .center)
                .accessibilityLabel(hit.significator.localizedName)

            if primDirModel.isEventMode {
                Text(formatOrb(hit.orbDays))
                    .frame(width: orbWidth, alignment: .trailing)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(orbColor(hit.orbDays))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Orb formatting

    private func formatOrb(_ days: Double?) -> String {
        guard let d = days else { return "" }
        let absD = Int(abs(d).rounded())
        if absD == 0 { return "0d" }
        return d < 0 ? "−\(absD)d" : "+\(absD)d"
    }

    private func orbColor(_ days: Double?) -> Color {
        guard let d = days else { return .primary }
        return d < 0 ? .secondary : .primary
    }
}
