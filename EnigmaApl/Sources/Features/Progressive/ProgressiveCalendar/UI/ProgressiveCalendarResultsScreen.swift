// ProgressiveCalendarResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ProgressiveCalendar", bundle: .main, comment: "")
}

/// Table results for the Progressive Calendar: one section per technique (Transit / Secondary
/// / Symbolic), each with an "Aspects & Parallels" subsection (orb episodes) and an
/// "Other events" subsection (instantaneous events — stations, cusp conjunctions, OOB,
/// declination extremes).
struct ProgressiveCalendarResultsScreen: View {
    @EnvironmentObject private var model: ProgressiveCalendarModel
    @State private var showHelp = false

    private let glyphW: CGFloat = 32
    private let dateW: CGFloat = 150
    private let orbW: CGFloat = 70
    private let targetW: CGFloat = 60
    private let typeW: CGFloat = 60
    private let posW: CGFloat = 110

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(t(ProgressiveCalendarKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if model.isCalculating {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(t(ProgressiveCalendarKeys.calculating)).foregroundStyle(.secondary).font(.callout)
                    }
                } else if model.hasResults {
                    ForEach(presentTechniques, id: \.self) { technique in
                        techniqueDiagramSection(technique)
                    }
                    ForEach(presentTechniques, id: \.self) { technique in
                        techniqueTablesSection(technique)
                    }
                } else if let err = model.errorMessage {
                    Text(err).font(.callout).foregroundStyle(.red)
                } else {
                    Text(t(ProgressiveCalendarKeys.noResults)).foregroundStyle(.secondary).font(.callout)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(ProgressiveCalendarKeys.resultsTitle))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(ProgressiveCalendarKeys.helpResults))
        }
    }

    // MARK: - Technique grouping

    private static let orderedTechniques: [ProgressiveCalendarTechnique] = [.transit, .secondaryDirection, .symbolicDirection]

    private var presentTechniques: [ProgressiveCalendarTechnique] {
        Self.orderedTechniques.filter { technique in
            model.events.contains { $0.technique == technique } ||
            model.episodes.contains { $0.technique == technique }
        }
    }

    private func techniqueTitle(_ technique: ProgressiveCalendarTechnique) -> String {
        switch technique {
        case .transit:            return t(ProgressiveCalendarKeys.useTransits)
        case .secondaryDirection: return t(ProgressiveCalendarKeys.useSecondaryDirections)
        case .symbolicDirection:  return t(ProgressiveCalendarKeys.useSymbolicDirections)
        }
    }

    @ViewBuilder
    private func techniqueDiagramSection(_ technique: ProgressiveCalendarTechnique) -> some View {
        let techniqueEpisodes = model.episodes.filter { $0.technique == technique }
            .sorted { ($0.enterJD ?? $0.exactJD) < ($1.enterJD ?? $1.exactJD) }
        let techniqueEvents = model.events.filter { $0.technique == technique }
            .sorted { $0.jd < $1.jd }

        if let startJD = model.lastStartJD, let endJD = model.lastEndJD {
            VStack(alignment: .leading, spacing: 12) {
                Text(techniqueTitle(technique))
                    .font(.title3.weight(.semibold))
                subsectionHeader(t(ProgressiveCalendarKeys.sectionDiagram))
                ProgressiveCalendarTimelineCanvas(
                    episodes: techniqueEpisodes, events: techniqueEvents,
                    startJD: startJD, endJD: endJD
                )
            }
        }
    }

    @ViewBuilder
    private func techniqueTablesSection(_ technique: ProgressiveCalendarTechnique) -> some View {
        let techniqueEpisodes = model.episodes.filter { $0.technique == technique }
            .sorted { ($0.enterJD ?? $0.exactJD) < ($1.enterJD ?? $1.exactJD) }
        let techniqueEvents = model.events.filter { $0.technique == technique }
            .sorted { $0.jd < $1.jd }

        VStack(alignment: .leading, spacing: 12) {
            Text(techniqueTitle(technique))
                .font(.title3.weight(.semibold))

            if !techniqueEpisodes.isEmpty {
                subsectionHeader(t(ProgressiveCalendarKeys.sectionAspectsParallels))
                episodesTable(techniqueEpisodes)
            }
            if !techniqueEvents.isEmpty {
                subsectionHeader(t(ProgressiveCalendarKeys.sectionOtherEvents))
                eventsTable(techniqueEvents)
            }
        }
    }

    private func subsectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
    }

    // MARK: - Episodes table (aspects & parallels)

    private func episodesTable(_ episodes: [ProgressiveOrbEpisode]) -> some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    episodesHeader
                    Divider()
                    ForEach(Array(episodes.enumerated()), id: \.offset) { index, episode in
                        episodeRow(episode, index: index)
                    }
                }
            }
        }
    }

    private var episodesHeader: some View {
        HStack(spacing: 8) {
            Spacer().frame(width: glyphW)
            Spacer().frame(width: glyphW)
            Spacer().frame(width: glyphW)
            Spacer().frame(width: targetW)
            Text(t(ProgressiveCalendarKeys.colEnter))
                .frame(width: dateW, alignment: .leading)
            Text(t(ProgressiveCalendarKeys.colExact))
                .frame(width: dateW, alignment: .leading)
            Text(t(ProgressiveCalendarKeys.colExit))
                .frame(width: dateW, alignment: .leading)
            Text(t(ProgressiveCalendarKeys.colOrb))
                .frame(width: orbW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func episodeRow(_ episode: ProgressiveOrbEpisode, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(episode.factor1))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            Text(episodeKindGlyph(episode.kind))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            Text(GlyphSelector.getGlyphForFactor(episode.factor2))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            Text(episodeTargetLabel(episode.kind))
                .frame(width: targetW, alignment: .leading)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(episode.enterJD.map(dateTimeStr) ?? "—")
                .frame(width: dateW, alignment: .leading)
                .font(.body.monospacedDigit())
            Text(episode.becomesExact ? dateTimeStr(episode.exactJD) : "—")
                .frame(width: dateW, alignment: .leading)
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
            Text(episode.exitJD.map(dateTimeStr) ?? "—")
                .frame(width: dateW, alignment: .leading)
                .font(.body.monospacedDigit())
            Text(orbText(episode.minOrb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    private func episodeKindGlyph(_ kind: ProgressiveOrbEpisodeKind) -> String {
        switch kind {
        case .aspectToRadix(let aspect), .aspectProgToProg(let aspect):
            return GlyphSelector.getGlyphForAspect(aspect)
        case .parallelToRadix, .parallelProgToProg:
            return "\u{F000}"
        case .contraParallelToRadix, .contraParallelProgToProg:
            return "\u{F010}"
        }
    }

    private func episodeTargetLabel(_ kind: ProgressiveOrbEpisodeKind) -> String {
        switch kind {
        case .aspectToRadix, .parallelToRadix, .contraParallelToRadix:
            return t(ProgressiveCalendarKeys.targetRadix)
        case .aspectProgToProg, .parallelProgToProg, .contraParallelProgToProg:
            return t(ProgressiveCalendarKeys.targetProg)
        }
    }

    // MARK: - Events table (other events)

    private func eventsTable(_ events: [ProgressiveCalendarEvent]) -> some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    eventsHeader
                    Divider()
                    ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                        eventRow(event, index: index)
                    }
                }
            }
        }
    }

    private var eventsHeader: some View {
        HStack(spacing: 8) {
            Spacer().frame(width: glyphW)
            Text("")
                .frame(width: typeW, alignment: .leading)
            Text(t(ProgressiveCalendarKeys.colDate))
                .frame(width: dateW, alignment: .leading)
            Text(t(ProgressiveCalendarKeys.colPosition))
                .frame(width: posW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func eventRow(_ event: ProgressiveCalendarEvent, index: Int) -> some View {
        let display = eventDisplay(event.kind)
        return HStack(spacing: 8) {
            Text(display.glyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            Text(display.label)
                .frame(width: typeW, alignment: .leading)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(event.dateTxt)
                .frame(width: dateW, alignment: .leading)
                .font(.body.monospacedDigit())
            positionView(for: event)
                .frame(width: posW, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    /// Positions show degrees/minutes with the zodiac sign glyph (rather than plain degrees)
    /// for every event kind, matching how positions are shown elsewhere in the app (e.g.
    /// `TransitResults`/`PreNatalResultsScreen`) — the sign glyph reads faster than a bare
    /// degree count.
    @ViewBuilder
    private func positionView(for event: ProgressiveCalendarEvent) -> some View {
        let (dms, sign, valid) = PositionInDegreesConversion.DoubleToDmsSign(event.longitude)
        HStack(spacing: 4) {
            Text(dms).font(.body.monospacedDigit())
            if valid, let sign {
                Text(GlyphSelector.getGlyphForSign(sign))
                    .font(.custom("EnigmaAstrology3", size: 14))
            }
        }
    }

    private func eventDisplay(_ kind: ProgressiveCalendarEventKind) -> (glyph: String, label: String) {
        switch kind {
        case .cuspConjunction(let factor, let cusp):
            return (GlyphSelector.getGlyphForFactor(factor) + GlyphSelector.getGlyphForAspect(.conjunction), cuspLabel(cusp))
        case .retrogradeStation(let factor):
            return (GlyphSelector.getGlyphForFactor(factor), "Rx")
        case .directStation(let factor):
            return (GlyphSelector.getGlyphForFactor(factor), "D")
        case .oobEnter(let factor):
            return (GlyphSelector.getGlyphForFactor(factor), t(ProgressiveCalendarKeys.typeOob) + " ↑")
        case .oobExit(let factor):
            return (GlyphSelector.getGlyphForFactor(factor), t(ProgressiveCalendarKeys.typeOob) + " ↓")
        case .zeroDeclination(let factor):
            return (GlyphSelector.getGlyphForFactor(factor), "0°")
        case .maxDeclination(let factor, let isNorthern):
            return (GlyphSelector.getGlyphForFactor(factor),
                    isNorthern ? t(ProgressiveCalendarKeys.typeDeclinationNorth) : t(ProgressiveCalendarKeys.typeDeclinationSouth))
        }
    }

    private func cuspLabel(_ cusp: ProgressiveCuspTarget) -> String {
        switch cusp {
        case .house(let number): return "H\(number)"
        case .ascendant: return "ASC"
        case .midheaven: return "MC"
        case .eastpoint: return "EP"
        case .vertex: return "VX"
        }
    }

    // MARK: - Formatting helpers

    private func orbText(_ orb: Double) -> String {
        let totalMin = Int(abs(orb) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
    }

    private func dateTimeStr(_ jd: Double) -> String {
        let se = SEWrapper()
        let dt = se.dateFromJulianDay(jd)
        let sec = min(dt.Time.Second, 59)
        return String(format: "%04d/%02d/%02d %02d:%02d:%02d",
                      dt.Date.Year, dt.Date.Month, dt.Date.Day,
                      dt.Time.Hour, dt.Time.Minute, sec)
    }
}
