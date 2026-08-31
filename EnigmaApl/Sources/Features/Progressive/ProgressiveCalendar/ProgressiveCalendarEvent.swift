// ProgressiveCalendarEvent.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The progressive technique that produced a Progressive Calendar event or episode.
/// Primary directions are intentionally excluded from the Progressive Calendar.
enum ProgressiveCalendarTechnique: Sendable {
    case transit
    case secondaryDirection
    case symbolicDirection
}

/// Identifies a house cusp or angle in the radix chart as the target of a
/// "conjunction with cusp" event.
enum ProgressiveCuspTarget: Sendable, Equatable {
    case house(Int)   // 1...12
    case ascendant
    case midheaven
    case eastpoint
    case vertex
}

/// A single, instantaneous Progressive Calendar event: something that happens at one
/// specific moment. Aspects and parallels are not modeled here — they span a range of
/// time and are represented by `ProgressiveOrbEpisode` instead.
enum ProgressiveCalendarEventKind: Sendable {
    case cuspConjunction(factor: Factors, cusp: ProgressiveCuspTarget)
    case retrogradeStation(factor: Factors)
    case directStation(factor: Factors)
    case oobEnter(factor: Factors)
    case oobExit(factor: Factors)
    case zeroDeclination(factor: Factors)
    case maxDeclination(factor: Factors, isNorthern: Bool)
}

/// An instantaneous Progressive Calendar event, for a given technique.
struct ProgressiveCalendarEvent: Identifiable, Sendable {
    let id = UUID()
    let technique: ProgressiveCalendarTechnique
    let jd: Double
    let dateTxt: String
    let kind: ProgressiveCalendarEventKind
    let longitude: Double

    init(technique: ProgressiveCalendarTechnique, jd: Double, dateTxt: String,
         kind: ProgressiveCalendarEventKind, longitude: Double) {
        self.technique = technique
        self.jd = jd
        self.dateTxt = dateTxt
        self.kind = kind
        self.longitude = longitude
    }
}

// MARK: - Orb-based episodes (aspects & parallels)

/// The relationship type for an orb-based episode. Prog-to-prog cases are scoped to a
/// single technique — cross-technique combinations (e.g. transit-to-secondary-direction)
/// are out of scope for the Progressive Calendar.
enum ProgressiveOrbEpisodeKind: Sendable, Equatable {
    case aspectToRadix(Aspects)
    case aspectProgToProg(Aspects)
    case parallelToRadix
    case contraParallelToRadix
    case parallelProgToProg
    case contraParallelProgToProg
}

/// A progressive aspect or parallel that is in orb for a span of time: it enters orb,
/// (usually) reaches its exact/minimum-orb moment, and leaves orb again.
///
/// `enterJD` is nil when the episode is already in orb at the start of the scanned date
/// range; `exitJD` is nil when it is still in orb at the end of the range. The table's
/// "becomes active" / "no longer active" rows and the diagram's grow/shrink width shape
/// are both derived directly from `enterJD`/`exactJD`/`exitJD`.
///
/// `becomesExact` is `false` when the progressive factor never actually reaches the exact
/// angle within the episode — typically because a retrograde/direct station reverses its
/// approach first, or because the true exact moment lies outside the scanned range entirely.
/// `exactJD`/`minOrb` still describe the closest approach found within the episode in that
/// case, but callers showing an "Exact" date to the user should treat it as not truly exact
/// (e.g. by hiding the date) rather than implying the aspect completed.
struct ProgressiveOrbEpisode: Identifiable, Sendable {
    let id = UUID()
    let technique: ProgressiveCalendarTechnique
    /// The progressive factor.
    let factor1: Factors
    /// The radix factor, or the second progressive factor for a prog-to-prog episode.
    let factor2: Factors
    let kind: ProgressiveOrbEpisodeKind
    let enterJD: Double?
    let exactJD: Double
    let exitJD: Double?
    let minOrb: Double
    let maxOrb: Double
    let becomesExact: Bool

    init(technique: ProgressiveCalendarTechnique, factor1: Factors, factor2: Factors,
         kind: ProgressiveOrbEpisodeKind, enterJD: Double?, exactJD: Double, exitJD: Double?,
         minOrb: Double, maxOrb: Double, becomesExact: Bool) {
        self.technique = technique
        self.factor1 = factor1
        self.factor2 = factor2
        self.kind = kind
        self.enterJD = enterJD
        self.exactJD = exactJD
        self.exitJD = exitJD
        self.minOrb = minOrb
        self.maxOrb = maxOrb
        self.becomesExact = becomesExact
    }
}
