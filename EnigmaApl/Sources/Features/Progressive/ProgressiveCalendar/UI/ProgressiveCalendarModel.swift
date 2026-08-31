// ProgressiveCalendarModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Editable session state for the Progressive Calendar input screen, plus scan results.
///
/// Like `PrimDirInputScreen`'s method/approach/timeKey, the editable settings below are
/// seeded from the persisted `ProgressiveCalendarConfig` via `syncFromConfig(_:)` but are not
/// written back to it from this screen — edits here apply only to the current calculation.
@MainActor
final class ProgressiveCalendarModel: ObservableObject {

    // MARK: - Editable settings

    @Published var useTransits: Bool
    @Published var useSecondaryDirections: Bool
    @Published var useSymbolicDirections: Bool

    @Published var transitFactors: [Factors]
    @Published var secondaryDirectionFactors: [Factors]
    @Published var symbolicDirectionFactors: [Factors]
    @Published var symbolicKey: SymbolicKeys

    @Published var radixFactors: [Factors]
    @Published var aspects: [Aspects]

    @Published var aspectOrb: Double
    @Published var parallelOrb: Double
    @Published var cuspOrb: Double

    @Published var useAspectsToRadix: Bool
    @Published var useParallelsToRadix: Bool
    @Published var useAspectsProgToProg: Bool
    @Published var useParallelsProgToProg: Bool
    @Published var useCuspConjunctions: Bool
    @Published var useRetrogradeDirectStations: Bool
    @Published var useOobEnterExit: Bool
    @Published var useDeclinationExtremes: Bool

    // MARK: - Results

    @Published private(set) var events: [ProgressiveCalendarEvent] = []
    @Published private(set) var episodes: [ProgressiveOrbEpisode] = []
    /// The date range actually scanned by the most recent successful `calculate` call — used
    /// by the timeline diagram's x-axis. `nil` until a calculation has completed.
    @Published private(set) var lastStartJD: Double?
    @Published private(set) var lastEndJD: Double?
    @Published var isCalculating = false
    @Published var errorMessage: String?
    @Published var inputErrorMessage: String?

    var hasResults: Bool { !events.isEmpty || !episodes.isEmpty }

    /// Selectable factors for all four factor pickers (transit/secondary/symbolic/radix).
    static let selectableFactors: [Factors] = PreNatalOrchestrator.selectableFactors

    init(config: ProgressiveCalendarConfig = ProgressiveCalendarConfig()) {
        useTransits = config.useTransits
        useSecondaryDirections = config.useSecondaryDirections
        useSymbolicDirections = config.useSymbolicDirections
        transitFactors = config.transitFactors
        secondaryDirectionFactors = config.secondaryDirectionFactors
        symbolicDirectionFactors = config.symbolicDirectionFactors
        symbolicKey = config.symbolicKey
        radixFactors = config.radixFactors
        aspects = config.aspects
        aspectOrb = config.aspectOrb
        parallelOrb = config.parallelOrb
        cuspOrb = config.cuspOrb
        useAspectsToRadix = config.useAspectsToRadix
        useParallelsToRadix = config.useParallelsToRadix
        useAspectsProgToProg = config.useAspectsProgToProg
        useParallelsProgToProg = config.useParallelsProgToProg
        useCuspConjunctions = config.useCuspConjunctions
        useRetrogradeDirectStations = config.useRetrogradeDirectStations
        useOobEnterExit = config.useOobEnterExit
        useDeclinationExtremes = config.useDeclinationExtremes
    }

    /// Reverts every editable setting to the given persisted config ("reset to saved
    /// settings"). Does not touch results.
    func syncFromConfig(_ config: ProgressiveCalendarConfig) {
        useTransits = config.useTransits
        useSecondaryDirections = config.useSecondaryDirections
        useSymbolicDirections = config.useSymbolicDirections
        transitFactors = config.transitFactors
        secondaryDirectionFactors = config.secondaryDirectionFactors
        symbolicDirectionFactors = config.symbolicDirectionFactors
        symbolicKey = config.symbolicKey
        radixFactors = config.radixFactors
        aspects = config.aspects
        aspectOrb = config.aspectOrb
        parallelOrb = config.parallelOrb
        cuspOrb = config.cuspOrb
        useAspectsToRadix = config.useAspectsToRadix
        useParallelsToRadix = config.useParallelsToRadix
        useAspectsProgToProg = config.useAspectsProgToProg
        useParallelsProgToProg = config.useParallelsProgToProg
        useCuspConjunctions = config.useCuspConjunctions
        useRetrogradeDirectStations = config.useRetrogradeDirectStations
        useOobEnterExit = config.useOobEnterExit
        useDeclinationExtremes = config.useDeclinationExtremes
    }

    /// Whether the current editable settings differ from the given persisted config.
    func isModified(against config: ProgressiveCalendarConfig) -> Bool {
        useTransits != config.useTransits ||
        useSecondaryDirections != config.useSecondaryDirections ||
        useSymbolicDirections != config.useSymbolicDirections ||
        transitFactors != config.transitFactors ||
        secondaryDirectionFactors != config.secondaryDirectionFactors ||
        symbolicDirectionFactors != config.symbolicDirectionFactors ||
        symbolicKey != config.symbolicKey ||
        radixFactors != config.radixFactors ||
        aspects != config.aspects ||
        aspectOrb != config.aspectOrb ||
        parallelOrb != config.parallelOrb ||
        cuspOrb != config.cuspOrb ||
        useAspectsToRadix != config.useAspectsToRadix ||
        useParallelsToRadix != config.useParallelsToRadix ||
        useAspectsProgToProg != config.useAspectsProgToProg ||
        useParallelsProgToProg != config.useParallelsProgToProg ||
        useCuspConjunctions != config.useCuspConjunctions ||
        useRetrogradeDirectStations != config.useRetrogradeDirectStations ||
        useOobEnterExit != config.useOobEnterExit ||
        useDeclinationExtremes != config.useDeclinationExtremes
    }

    // MARK: - Derived

    /// The techniques currently enabled, each with its factor list (and symbolic key, where
    /// applicable). A technique with no factors selected is omitted.
    var activeSelections: [ProgressiveCalendarOrchestrator.Selection] {
        var result: [ProgressiveCalendarOrchestrator.Selection] = []
        if useTransits, !transitFactors.isEmpty {
            result.append(.init(technique: .transit, factors: transitFactors))
        }
        if useSecondaryDirections, !secondaryDirectionFactors.isEmpty {
            result.append(.init(technique: .secondaryDirection, factors: secondaryDirectionFactors))
        }
        if useSymbolicDirections, !symbolicDirectionFactors.isEmpty {
            result.append(.init(technique: .symbolicDirection, factors: symbolicDirectionFactors, symbolicKey: symbolicKey))
        }
        return result
    }

    /// The maximum allowed span, in days, between the scan's start and end date, for the
    /// currently active selections.
    var maxRangeInDays: Double {
        ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: activeSelections)
    }

    // MARK: - Calculate

    func calculate(startDateText: String, endDateText: String, natalJD: Double, radixChart: FullChart) {
        guard !isCalculating else { return }
        errorMessage = nil
        inputErrorMessage = nil

        let seWrapper = SEWrapper()
        guard let startJD = Self.parseDate(startDateText, seWrapper: seWrapper) else {
            inputErrorMessage = Self.localized(ProgressiveCalendarKeys.errorInvalidStartDate)
            return
        }
        guard let endJD = Self.parseDate(endDateText, seWrapper: seWrapper) else {
            inputErrorMessage = Self.localized(ProgressiveCalendarKeys.errorInvalidEndDate)
            return
        }
        guard endJD > startJD else {
            inputErrorMessage = Self.localized(ProgressiveCalendarKeys.errorEndBeforeStart)
            return
        }

        let selections = activeSelections
        guard !selections.isEmpty else {
            inputErrorMessage = Self.localized(ProgressiveCalendarKeys.errorNoTechnique)
            return
        }

        let limit = ProgressiveCalendarRangeLimiter.maxRangeInDays(selections: selections)
        let requestedDays = endJD - startJD
        guard requestedDays <= limit else {
            inputErrorMessage = String(format: Self.localized(ProgressiveCalendarKeys.errorRangeTooLong),
                                        Int(limit.rounded()), Int(requestedDays.rounded()))
            return
        }

        isCalculating = true
        events = []
        episodes = []
        lastStartJD = startJD
        lastEndJD = endJD

        let radixFactorsCopy = radixFactors
        let aspectsCopy = aspects
        let aspectOrbCopy = aspectOrb
        let parallelOrbCopy = parallelOrb
        let cuspOrbCopy = cuspOrb
        var toggles = ProgressiveCalendarOrchestrator.EventKindToggles()
        toggles.aspectsToRadix = useAspectsToRadix
        toggles.parallelsToRadix = useParallelsToRadix
        toggles.aspectsProgToProg = useAspectsProgToProg
        toggles.parallelsProgToProg = useParallelsProgToProg
        toggles.cuspConjunctions = useCuspConjunctions
        toggles.retrogradeDirectStations = useRetrogradeDirectStations
        toggles.oobEnterExit = useOobEnterExit
        toggles.declinationExtremes = useDeclinationExtremes

        Task.detached(priority: .userInitiated) { [natalJD, radixChart, startJD, endJD, selections,
                                                     radixFactorsCopy, aspectsCopy, aspectOrbCopy,
                                                     parallelOrbCopy, cuspOrbCopy, toggles] in
            let seWrapper = SEWrapper()
            let orchestrator = ProgressiveCalendarOrchestrator(natalJD: natalJD, radixChart: radixChart, seWrapper: seWrapper)
            let result = orchestrator.findEvents(
                startJD: startJD, endJD: endJD,
                selections: selections,
                radixFactors: radixFactorsCopy,
                aspects: aspectsCopy,
                aspectOrb: aspectOrbCopy, parallelOrb: parallelOrbCopy, cuspOrb: cuspOrbCopy,
                toggles: toggles
            )
            await MainActor.run {
                self.events = result.events
                self.episodes = result.episodes
                self.isCalculating = false
                if result.events.isEmpty && result.episodes.isEmpty {
                    self.errorMessage = Self.localized(ProgressiveCalendarKeys.noHits)
                }
            }
        }
    }

    func clear() {
        events = []
        episodes = []
        lastStartJD = nil
        lastEndJD = nil
        errorMessage = nil
        inputErrorMessage = nil
    }

    // MARK: - Helpers

    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ProgressiveCalendar", bundle: .main, comment: "")
    }

    private static func parseDate(_ text: String, seWrapper: SEWrapper) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let parts = trimmed.components(separatedBy: CharacterSet(charactersIn: "/-."))
        guard parts.count == 3,
              let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]),
              m >= 1 && m <= 12, d >= 1 && d <= 31 else { return nil }
        let date = AstronomicalDate(Year: y, Month: m, Day: d, Gregorian: true)
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        return seWrapper.julianDay(date: date, time: time)
    }
}
