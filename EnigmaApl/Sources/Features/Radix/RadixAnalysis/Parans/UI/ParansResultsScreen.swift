// ParansResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Parans", bundle: .main, comment: "")
}

struct ParansResultsScreen: View {
    @EnvironmentObject private var paranModel:   ParansModel
    @EnvironmentObject private var chartSession: ChartSession

    @State private var selectedTab: ParansTab = .positions
    @State private var showHelp = false

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(ParansKeys.title),
                    systemImage: "star.circle",
                    description: Text(t(ParansKeys.noChart))
                )
            } else if paranModel.isCalculating {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(t(ParansKeys.calculating))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let result = paranModel.result {
                VStack(alignment: .leading, spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text(t(ParansKeys.tabPositions)).tag(ParansTab.positions)
                        Text(t(ParansKeys.tabMatches)).tag(ParansTab.matches)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 280)
                    .padding([.horizontal, .top])

                    Divider().padding(.top, 8)

                    switch selectedTab {
                    case .positions: ParansPositionsTab(allTimes: result.allTimes)
                    case .matches:   ParansMatchesTab(matches: result.matches)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(ParansKeys.helpResults))
        }
    }
}

// MARK: - Tab enum

private enum ParansTab { case positions, matches }

// MARK: - Positions tab

private struct ParansPositionsTab: View {
    let allTimes: [ParanTimesForBody]

    private let nameW: CGFloat = 160
    private let timeW: CGFloat = 70

    var body: some View {
        if allTimes.isEmpty {
            ContentUnavailableView(t(ParansKeys.noResults), systemImage: "star.slash")
                .padding()
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    headerRow
                    Divider()
                    ForEach(Array(allTimes.enumerated()), id: \.offset) { index, entry in
                        positionRow(entry, index: index)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text(t(ParansKeys.colName))
                .frame(width: nameW, alignment: .leading)
            Text(t(ParansKeys.colRising))
                .frame(width: timeW, alignment: .trailing)
            Text(t(ParansKeys.colSetting))
                .frame(width: timeW, alignment: .trailing)
            Text(t(ParansKeys.colCulmination))
                .frame(width: timeW, alignment: .trailing)
            Text(t(ParansKeys.colAntiCulm))
                .frame(width: timeW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private func positionRow(_ entry: ParanTimesForBody, index: Int) -> some View {
        HStack(spacing: 8) {
            bodyLabel(entry.body)
                .frame(width: nameW, alignment: .leading)
            timeText(entry.rising)
                .frame(width: timeW, alignment: .trailing)
            timeText(entry.setting)
                .frame(width: timeW, alignment: .trailing)
            timeText(entry.culmination)
                .frame(width: timeW, alignment: .trailing)
            timeText(entry.antiCulmination)
                .frame(width: timeW, alignment: .trailing)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 5)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private func bodyLabel(_ body: ParanBody) -> some View {
        switch body {
        case .factor(let f):
            HStack(spacing: 4) {
                Text(GlyphSelector.getGlyphForFactor(f))
                    .font(.custom("EnigmaAstrology2", size: 16))
                    .frame(width: 20, alignment: .center)
                Text(NSLocalizedString(f.localizedName, comment: ""))
                    .lineLimit(1)
            }
        case .star(let s):
            Text(s.name)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private func timeText(_ jd: Double?) -> some View {
        if let jd {
            Text(formatTime(jd))
                .monospacedDigit()
                .font(.callout)
        } else {
            Text("—")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Matches tab

private struct ParansMatchesTab: View {
    let matches: [ParanMatch]

    private let body1W: CGFloat = 130
    private let type1W: CGFloat = 80
    private let body2W: CGFloat = 120
    private let type2W: CGFloat = 80
    private let timeW:  CGFloat = 55
    private let orbW:   CGFloat = 60

    var body: some View {
        if matches.isEmpty {
            ContentUnavailableView(t(ParansKeys.noMatches), systemImage: "circle.slash")
                .padding()
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    headerRow
                    Divider()
                    ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                        matchRow(match, index: index)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text(t(ParansKeys.colBody1))
                .frame(width: body1W, alignment: .leading)
            Text(t(ParansKeys.colType1))
                .frame(width: type1W, alignment: .leading)
            Text(t(ParansKeys.colBody2))
                .frame(width: body2W, alignment: .leading)
            Text(t(ParansKeys.colType2))
                .frame(width: type2W, alignment: .leading)
            Text(t(ParansKeys.colTime))
                .frame(width: timeW, alignment: .trailing)
            Text(t(ParansKeys.colOrb))
                .frame(width: orbW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private func matchRow(_ match: ParanMatch, index: Int) -> some View {
        HStack(spacing: 8) {
            bodyLabel(match.body1)
                .frame(width: body1W, alignment: .leading)
            Text(typeLabel(match.type1))
                .frame(width: type1W, alignment: .leading)
                .lineLimit(1)
                .font(.callout)
            bodyLabel(match.body2)
                .frame(width: body2W, alignment: .leading)
            Text(typeLabel(match.type2))
                .frame(width: type2W, alignment: .leading)
                .lineLimit(1)
                .font(.callout)
            Text(formatTime(match.exactTime))
                .frame(width: timeW, alignment: .trailing)
                .monospacedDigit()
                .font(.callout)
            Text(formatOrb(match.orbMinutes))
                .frame(width: orbW, alignment: .trailing)
                .monospacedDigit()
                .font(.callout)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 5)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private func bodyLabel(_ body: ParanBody) -> some View {
        switch body {
        case .factor(let f):
            HStack(spacing: 4) {
                Text(GlyphSelector.getGlyphForFactor(f))
                    .font(.custom("EnigmaAstrology2", size: 16))
                    .frame(width: 20, alignment: .center)
                Text(NSLocalizedString(f.localizedName, comment: ""))
                    .lineLimit(1)
            }
        case .star(let s):
            Text(s.name)
                .lineLimit(1)
        }
    }

    private func typeLabel(_ type: ParanType) -> String {
        switch type {
        case .rising:          return t(ParansKeys.typeRising)
        case .setting:         return t(ParansKeys.typeSetting)
        case .culmination:     return t(ParansKeys.typeCulmination)
        case .antiCulmination: return t(ParansKeys.typeAntiCulm)
        }
    }
}

// MARK: - Shared formatting helpers

private func formatTime(_ jd: Double) -> String {
    let dt = SEWrapper().dateFromJulianDay(jd)
    return String(format: "%02d:%02d", dt.Time.Hour, dt.Time.Minute)
}

private func formatOrb(_ minutes: Double) -> String {
    let wholeMinutes = Int(minutes)
    let seconds = Int((minutes - Double(wholeMinutes)) * 60.0)
    return "\(wholeMinutes)'\(String(format: "%02d", seconds))\""
}
