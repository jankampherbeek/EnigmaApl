// FixStarResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "FixStar", bundle: .main, comment: "")
}

struct FixStarResultsScreen: View {
    @EnvironmentObject private var fixStarModel: FixStarModel
    @State private var showFactsheet = false
    @State private var showHelp = false

    var body: some View {
        Group {
            if let err = fixStarModel.errorMessage {
                ContentUnavailableView(err, systemImage: "exclamationmark.triangle")
            } else if fixStarModel.positionEntries.isEmpty {
                ContentUnavailableView(t(FixStarKeys.noResults), systemImage: "star.slash")
            } else {
                TabView {
                    FixStarPositionsTab()
                        .tabItem { Text(t(FixStarKeys.tabPositions)) }
                    FixStarMatchesTab()
                        .tabItem { Text(t(FixStarKeys.tabMatches)) }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "fixstars")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(FixStarKeys.helpResults))
        }
    }
}

// MARK: - Positions tab

private struct FixStarPositionsTab: View {
    @EnvironmentObject private var fixStarModel: FixStarModel

    var body: some View {
        List {
            HStack {
                Text(t(FixStarKeys.colName))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.semibold)
                Text(t(FixStarKeys.colLongitude))
                    .frame(width: 130, alignment: .trailing)
                    .fontWeight(.semibold)
                Text(t(FixStarKeys.colLatitude))
                    .frame(width: 90, alignment: .trailing)
                    .fontWeight(.semibold)
                Text(t(FixStarKeys.colDeclination))
                    .frame(width: 90, alignment: .trailing)
                    .fontWeight(.semibold)
            }
            .listRowBackground(Color.primary.opacity(0.06))

            ForEach(Array(fixStarModel.positionEntries.enumerated()), id: \.element.id) { index, entry in
                HStack {
                    Text(entry.displayName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    longitudeView(entry.result.longitude)
                    Text(PositionInDegreesConversion.DoubleToDms(entry.result.latitude))
                        .frame(width: 90, alignment: .trailing)
                        .monospacedDigit()
                    Text(PositionInDegreesConversion.DoubleToDms(entry.result.declination))
                        .frame(width: 90, alignment: .trailing)
                        .monospacedDigit()
                }
                .listRowBackground(index % 2 == 1 ? Color.primary.opacity(0.06) : Color.clear)
            }
        }
    }

    @ViewBuilder
    private func longitudeView(_ value: Double) -> some View {
        let (dmsString, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(value)
        HStack(spacing: 2) {
            Text(dmsString).monospacedDigit()
            if let sign {
                Text(GlyphSelector.getGlyphForSign(sign))
                    .font(.custom("EnigmaAstrology2", size: 14))
            }
        }
        .frame(width: 130, alignment: .trailing)
    }
}

// MARK: - Matches tab

private struct FixStarMatchesTab: View {
    @EnvironmentObject private var fixStarModel: FixStarModel

    var body: some View {
        if fixStarModel.matches.isEmpty {
            ContentUnavailableView(t(FixStarKeys.noResults), systemImage: "star.slash")
        } else {
            List {
                HStack {
                    Text(t(FixStarKeys.colName))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(.semibold)
                    Text(t(FixStarKeys.colFactor))
                        .frame(width: 30, alignment: .center)
                        .fontWeight(.semibold)
                    Text(t(FixStarKeys.colType))
                        .frame(width: 110, alignment: .leading)
                        .fontWeight(.semibold)
                    Text(t(FixStarKeys.colOrb))
                        .frame(width: 80, alignment: .trailing)
                        .fontWeight(.semibold)
                }
                .listRowBackground(Color.primary.opacity(0.06))

                ForEach(Array(fixStarModel.matches.enumerated()), id: \.element.id) { index, match in
                    HStack {
                        Text(match.starName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(GlyphSelector.getGlyphForFactor(match.factor))
                            .font(.custom("EnigmaAstrology2", size: 16))
                            .frame(width: 30, alignment: .center)
                        Text(typeLabel(match.matchType))
                            .frame(width: 110, alignment: .leading)
                        Text(PositionInDegreesConversion.DoubleToDms(match.orb))
                            .frame(width: 80, alignment: .trailing)
                            .monospacedDigit()
                    }
                    .listRowBackground(index % 2 == 1 ? Color.primary.opacity(0.06) : Color.clear)
                }
            }
        }
    }

    private func typeLabel(_ type: FixStarMatch.MatchType) -> String {
        switch type {
        case .conjunction: return t(FixStarKeys.matchConjunction)
        case .parallel:    return t(FixStarKeys.matchParallel)
        }
    }
}
