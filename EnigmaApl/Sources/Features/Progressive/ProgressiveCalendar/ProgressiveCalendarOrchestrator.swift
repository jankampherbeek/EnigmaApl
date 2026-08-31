// ProgressiveCalendarOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Finds Progressive Calendar events and orb episodes over a date range, for the transit,
/// secondary-direction and symbolic-direction techniques. Primary directions are out of
/// scope for the Progressive Calendar.
///
/// This orchestrator does not enforce the date-range performance limit (see the Progressive
/// Calendar project memory for the limiter rule) — that is the caller's responsibility,
/// applied before `findEvents` is invoked.
///
/// Symbolic directions are longitude-only in this app (`ProgressiveOrchestrator` sets their
/// declination to 0) and their arc always increases, so for `.symbolicDirection` this
/// orchestrator only produces longitude-based results: aspects to radix, aspects between
/// symbolic factors, and cusp conjunctions. Declination-based event kinds (zero/max
/// declination, OOB enter/exit) and parallels never fire for symbolic directions, and
/// symbolic directions never produce retrograde/direct stations.
struct ProgressiveCalendarOrchestrator {

    private let natalJD: Double
    private let radixChart: FullChart
    private let seWrapper: SEWrapper

    private static let TROPICAL_YEAR_IN_DAYS = 365.242199074
    private static let ZERO_CROSSING_TOLERANCE = 1e-6
    /// Small backward probe, in days, used to read the sign of a quantity just before a
    /// detected zero crossing (e.g. to classify a station as retrograde vs. direct).
    private static let DIRECTION_PROBE = 1e-4
    /// Threshold used to reject spurious sign changes caused by circular wraparound (e.g. an
    /// angular deviation jumping from +179° to −179°), mirroring `PreNatalOrchestrator`.
    private static let WRAPAROUND_GUARD_SUM = 90.0

    init(natalJD: Double, radixChart: FullChart, seWrapper: SEWrapper) {
        self.natalJD = natalJD
        self.radixChart = radixChart
        self.seWrapper = seWrapper
    }

    // MARK: - Public API

    struct Selection {
        let technique: ProgressiveCalendarTechnique
        let factors: [Factors]
        /// Required, and only meaningful, for `.symbolicDirection`.
        let symbolicKey: SymbolicKeys?

        init(technique: ProgressiveCalendarTechnique, factors: [Factors], symbolicKey: SymbolicKeys? = nil) {
            self.technique = technique
            self.factors = factors
            self.symbolicKey = symbolicKey
        }
    }

    struct EventKindToggles {
        var aspectsToRadix = true
        var parallelsToRadix = true
        var aspectsProgToProg = true
        var parallelsProgToProg = true
        var cuspConjunctions = true
        var retrogradeDirectStations = true
        var oobEnterExit = true
        var declinationExtremes = true

        init() {}
    }

    struct Result {
        let events: [ProgressiveCalendarEvent]
        let episodes: [ProgressiveOrbEpisode]
    }

    /// Scans `[startJD, endJD]` for Progressive Calendar events and orb episodes.
    /// - Parameters:
    ///   - selections: one entry per technique to include, each with its own factor list.
    ///   - radixFactors: radix factors to compare progressive factors against.
    ///   - aspects: aspect angles considered for both radix and prog-to-prog aspects.
    ///   - aspectOrb: maximum orb, in degrees, for aspect episodes.
    ///   - parallelOrb: maximum orb, in degrees, for parallel/contra-parallel episodes.
    ///   - cuspOrb: currently unused — cusp conjunctions are found as exact crossings, not
    ///     orb episodes. Reserved for a future orb-window variant.
    func findEvents(
        startJD: Double,
        endJD: Double,
        selections: [Selection],
        radixFactors: [Factors],
        aspects: [Aspects],
        aspectOrb: Double,
        parallelOrb: Double,
        cuspOrb: Double,
        toggles: EventKindToggles
    ) -> Result {
        var events: [ProgressiveCalendarEvent] = []
        var episodes: [ProgressiveOrbEpisode] = []

        for selection in selections {
            let provider = techniqueProvider(for: selection)
            let step = Self.stepSizeInDays(technique: selection.technique, factors: selection.factors)

            if toggles.retrogradeDirectStations, provider.supportsSpeed {
                events += findStations(technique: selection.technique, factors: selection.factors,
                                        startJD: startJD, endJD: endJD, stepSize: step, provider: provider)
            }
            if toggles.declinationExtremes, provider.supportsDeclination {
                events += findZeroDeclinations(technique: selection.technique, factors: selection.factors,
                                                startJD: startJD, endJD: endJD, stepSize: step, provider: provider)
                events += findDeclinationExtremes(technique: selection.technique, factors: selection.factors,
                                                   startJD: startJD, endJD: endJD, stepSize: step, provider: provider)
            }
            if toggles.oobEnterExit, provider.supportsDeclination {
                events += findOobTransitions(technique: selection.technique, factors: selection.factors,
                                              startJD: startJD, endJD: endJD, stepSize: step, provider: provider)
            }
            if toggles.cuspConjunctions {
                events += findCuspConjunctions(technique: selection.technique, factors: selection.factors,
                                                startJD: startJD, endJD: endJD, stepSize: step, provider: provider)
            }
            if toggles.aspectsToRadix {
                episodes += findAspectEpisodesToRadix(technique: selection.technique, factors: selection.factors,
                                                        radixFactors: radixFactors, aspects: aspects,
                                                        startJD: startJD, endJD: endJD, stepSize: step,
                                                        provider: provider, maxOrb: aspectOrb)
            }
            if toggles.parallelsToRadix, provider.supportsDeclination {
                episodes += findParallelEpisodesToRadix(technique: selection.technique, factors: selection.factors,
                                                          radixFactors: radixFactors,
                                                          startJD: startJD, endJD: endJD, stepSize: step,
                                                          provider: provider, maxOrb: parallelOrb)
            }
            if toggles.aspectsProgToProg {
                episodes += findAspectEpisodesProgToProg(technique: selection.technique, factors: selection.factors,
                                                          aspects: aspects, startJD: startJD, endJD: endJD,
                                                          stepSize: step, provider: provider, maxOrb: aspectOrb)
            }
            if toggles.parallelsProgToProg, provider.supportsDeclination {
                episodes += findParallelEpisodesProgToProg(technique: selection.technique, factors: selection.factors,
                                                            startJD: startJD, endJD: endJD, stepSize: step,
                                                            provider: provider, maxOrb: parallelOrb)
            }
        }

        return Result(
            events: events.sorted { $0.jd < $1.jd },
            episodes: episodes.sorted { ($0.enterJD ?? $0.exactJD) < ($1.enterJD ?? $1.exactJD) }
        )
    }

    // MARK: - Position providers

    /// Supplies longitude/declination (and, where supported, their speeds) for a progressive
    /// factor at a given real-world Julian Day, for one technique.
    private struct TechniqueProvider {
        let supportsSpeed: Bool
        let supportsDeclination: Bool
        let longitude: (Factors, Double) -> Double
        let longitudeSpeed: (Factors, Double) -> Double
        let declination: (Factors, Double) -> Double
        let declinationSpeed: (Factors, Double) -> Double
    }

    private func techniqueProvider(for selection: Selection) -> TechniqueProvider {
        switch selection.technique {
        case .transit:
            return ephemerisProvider(internalJD: { realJD in realJD })
        case .secondaryDirection:
            return ephemerisProvider(internalJD: { realJD in
                natalJD + (realJD - natalJD) / Self.TROPICAL_YEAR_IN_DAYS
            })
        case .symbolicDirection:
            return symbolicProvider(symbolicKey: selection.symbolicKey ?? .oneDegree)
        }
    }

    /// Shared provider for transits and secondary directions: both reduce to evaluating the
    /// real ephemeris at some internal Julian Day derived from the real-world Julian Day.
    private func ephemerisProvider(internalJD: @escaping (Double) -> Double) -> TechniqueProvider {
        TechniqueProvider(
            supportsSpeed: true,
            supportsDeclination: true,
            longitude: { factor, realJD in
                calcLongitude(factor, internalJD(realJD))
            },
            longitudeSpeed: { factor, realJD in
                calcLongitudeSpeed(factor, internalJD(realJD))
            },
            declination: { factor, realJD in
                calcDeclination(factor, internalJD(realJD))
            },
            declinationSpeed: { factor, realJD in
                calcDeclinationSpeed(factor, internalJD(realJD))
            }
        )
    }

    /// Symbolic directions: longitude = natal longitude + arc(realJD). No speed or
    /// declination is modeled, matching `ProgressiveOrchestrator`.
    private func symbolicProvider(symbolicKey: SymbolicKeys) -> TechniqueProvider {
        let natalLongitude: (Factors) -> Double = { factor in
            calcLongitude(factor, natalJD)
        }
        let sunNatalLongitude = natalLongitude(.sun)

        func arc(_ realJD: Double) -> Double {
            let oneDegreeArc = (realJD - natalJD) / Self.TROPICAL_YEAR_IN_DAYS
            switch symbolicKey {
            case .oneDegree:
                return oneDegreeArc
            case .meanSun:
                return (360.0 / Self.TROPICAL_YEAR_IN_DAYS) * oneDegreeArc
            case .trueSun:
                let sunAtDirected = calcLongitude(.sun, natalJD + oneDegreeArc)
                var diff = sunAtDirected - sunNatalLongitude
                diff = diff.truncatingRemainder(dividingBy: 360.0)
                if diff < 0 { diff += 360.0 }
                return diff
            }
        }

        return TechniqueProvider(
            supportsSpeed: false,
            supportsDeclination: false,
            longitude: { factor, realJD in
                var lon = natalLongitude(factor) + arc(realJD)
                lon = lon.truncatingRemainder(dividingBy: 360.0)
                if lon < 0 { lon += 360.0 }
                return lon
            },
            longitudeSpeed: { _, _ in 0.0 },
            declination: { _, _ in 0.0 },
            declinationSpeed: { _, _ in 0.0 }
        )
    }

    // MARK: - Instantaneous events: stations

    private func findStations(
        technique: ProgressiveCalendarTechnique, factors: [Factors],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider
    ) -> [ProgressiveCalendarEvent] {
        factors.flatMap { factor -> [ProgressiveCalendarEvent] in
            let crossings = ZeroCrossingScanner.scan(
                startJD: startJD, endJD: endJD, stepSize: { _ in stepSize },
                tolerance: Self.ZERO_CROSSING_TOLERANCE,
                f: { jd in provider.longitudeSpeed(factor, jd) }
            )
            return crossings.map { jd in
                let speedBefore = provider.longitudeSpeed(factor, max(startJD, jd - Self.DIRECTION_PROBE))
                let kind: ProgressiveCalendarEventKind =
                    speedBefore > 0 ? .retrogradeStation(factor: factor) : .directStation(factor: factor)
                return makeEvent(technique: technique, jd: jd, kind: kind, longitude: provider.longitude(factor, jd))
            }
        }
    }

    // MARK: - Instantaneous events: declination

    private func findZeroDeclinations(
        technique: ProgressiveCalendarTechnique, factors: [Factors],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider
    ) -> [ProgressiveCalendarEvent] {
        factors.flatMap { factor -> [ProgressiveCalendarEvent] in
            ZeroCrossingScanner.scan(
                startJD: startJD, endJD: endJD, stepSize: { _ in stepSize },
                tolerance: Self.ZERO_CROSSING_TOLERANCE,
                f: { jd in provider.declination(factor, jd) }
            ).map { jd in
                makeEvent(technique: technique, jd: jd, kind: .zeroDeclination(factor: factor),
                          longitude: provider.longitude(factor, jd))
            }
        }
    }

    /// A declination extreme (maximum north or south) is a moment where the derivative of
    /// declination — declination speed — crosses zero.
    private func findDeclinationExtremes(
        technique: ProgressiveCalendarTechnique, factors: [Factors],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider
    ) -> [ProgressiveCalendarEvent] {
        factors.flatMap { factor -> [ProgressiveCalendarEvent] in
            ZeroCrossingScanner.scan(
                startJD: startJD, endJD: endJD, stepSize: { _ in stepSize },
                tolerance: Self.ZERO_CROSSING_TOLERANCE,
                f: { jd in provider.declinationSpeed(factor, jd) }
            ).map { jd in
                let isNorthern = provider.declination(factor, jd) >= 0
                return makeEvent(technique: technique, jd: jd, kind: .maxDeclination(factor: factor, isNorthern: isNorthern),
                                  longitude: provider.longitude(factor, jd))
            }
        }
    }

    private func findOobTransitions(
        technique: ProgressiveCalendarTechnique, factors: [Factors],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider
    ) -> [ProgressiveCalendarEvent] {
        func oobDeviation(_ factor: Factors, _ jd: Double) -> Double {
            abs(provider.declination(factor, jd)) - obliquity(at: jd)
        }
        return factors.flatMap { factor -> [ProgressiveCalendarEvent] in
            let crossings = ZeroCrossingScanner.scan(
                startJD: startJD, endJD: endJD, stepSize: { _ in stepSize },
                tolerance: Self.ZERO_CROSSING_TOLERANCE,
                f: { jd in oobDeviation(factor, jd) }
            )
            return crossings.map { jd in
                let wasOobBefore = oobDeviation(factor, max(startJD, jd - Self.DIRECTION_PROBE)) > 0
                let kind: ProgressiveCalendarEventKind = wasOobBefore ? .oobExit(factor: factor) : .oobEnter(factor: factor)
                return makeEvent(technique: technique, jd: jd, kind: kind, longitude: provider.longitude(factor, jd))
            }
        }
    }

    // MARK: - Instantaneous events: cusp conjunctions

    private func findCuspConjunctions(
        technique: ProgressiveCalendarTechnique, factors: [Factors],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider
    ) -> [ProgressiveCalendarEvent] {
        let targets = cuspTargets()
        return factors.flatMap { factor -> [ProgressiveCalendarEvent] in
            targets.flatMap { (target, cuspLongitude) -> [ProgressiveCalendarEvent] in
                let crossings = ZeroCrossingScanner.scan(
                    startJD: startJD, endJD: endJD, stepSize: { _ in stepSize },
                    tolerance: Self.ZERO_CROSSING_TOLERANCE,
                    isPlausibleCrossing: { abs($0) + abs($1) < Self.WRAPAROUND_GUARD_SUM },
                    f: { jd in Self.signedDistance(provider.longitude(factor, jd), cuspLongitude) }
                )
                return crossings.map { jd in
                    makeEvent(technique: technique, jd: jd, kind: .cuspConjunction(factor: factor, cusp: target),
                              longitude: provider.longitude(factor, jd))
                }
            }
        }
    }

    private func cuspTargets() -> [(ProgressiveCuspTarget, Double)] {
        var targets: [(ProgressiveCuspTarget, Double)] = []
        let cusps = radixChart.HousePositions.cusps
        for i in 0..<min(12, cusps.count) {
            targets.append((.house(i + 1), cusps[i].longitude))
        }
        targets.append((.ascendant, radixChart.HousePositions.ascendant.longitude))
        targets.append((.midheaven, radixChart.HousePositions.midheaven.longitude))
        targets.append((.eastpoint, radixChart.HousePositions.eastpoint.longitude))
        targets.append((.vertex, radixChart.HousePositions.vertex.longitude))
        return targets
    }

    // MARK: - Orb episodes: aspects & parallels to radix

    private func findAspectEpisodesToRadix(
        technique: ProgressiveCalendarTechnique, factors: [Factors], radixFactors: [Factors], aspects: [Aspects],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider, maxOrb: Double
    ) -> [ProgressiveOrbEpisode] {
        let radixLongitudes = radixLongitudes(for: radixFactors)
        var episodes: [ProgressiveOrbEpisode] = []
        for factor in factors {
            for (radixFactor, radixLon) in radixLongitudes {
                for aspect in aspects {
                    let deviation: (Double) -> Double = { jd in
                        Self.signedAspectDeviation(provider.longitude(factor, jd), radixLon, aspectAngle: aspect.angle)
                    }
                    episodes += findOrbEpisodes(
                        technique: technique, factor1: factor, factor2: radixFactor,
                        kind: .aspectToRadix(aspect), deviation: deviation,
                        startJD: startJD, endJD: endJD, stepSize: stepSize, maxOrb: maxOrb
                    )
                }
            }
        }
        return episodes
    }

    private func findParallelEpisodesToRadix(
        technique: ProgressiveCalendarTechnique, factors: [Factors], radixFactors: [Factors],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider, maxOrb: Double
    ) -> [ProgressiveOrbEpisode] {
        let radixDeclinations = radixDeclinations(for: radixFactors)
        var episodes: [ProgressiveOrbEpisode] = []
        for factor in factors {
            for (radixFactor, radixDecl) in radixDeclinations {
                let deviation: (Double) -> Double = { jd in
                    abs(provider.declination(factor, jd)) - abs(radixDecl)
                }
                let raw = findOrbEpisodes(
                    technique: technique, factor1: factor, factor2: radixFactor,
                    kind: .parallelToRadix, deviation: deviation,
                    startJD: startJD, endJD: endJD, stepSize: stepSize, maxOrb: maxOrb
                )
                episodes += raw.map { episode in
                    let isContra = (provider.declination(factor, episode.exactJD) >= 0) != (radixDecl >= 0)
                    guard isContra else { return episode }
                    return ProgressiveOrbEpisode(
                        technique: episode.technique, factor1: episode.factor1, factor2: episode.factor2,
                        kind: .contraParallelToRadix, enterJD: episode.enterJD, exactJD: episode.exactJD,
                        exitJD: episode.exitJD, minOrb: episode.minOrb, maxOrb: episode.maxOrb,
                        becomesExact: episode.becomesExact
                    )
                }
            }
        }
        return episodes
    }

    // MARK: - Orb episodes: aspects & parallels between progressive factors (within technique)

    private func findAspectEpisodesProgToProg(
        technique: ProgressiveCalendarTechnique, factors: [Factors], aspects: [Aspects],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider, maxOrb: Double
    ) -> [ProgressiveOrbEpisode] {
        guard factors.count > 1 else { return [] }
        var episodes: [ProgressiveOrbEpisode] = []
        for i in 0..<factors.count {
            for j in (i + 1)..<factors.count {
                let f1 = factors[i], f2 = factors[j]
                for aspect in aspects {
                    let deviation: (Double) -> Double = { jd in
                        Self.signedAspectDeviation(provider.longitude(f1, jd), provider.longitude(f2, jd), aspectAngle: aspect.angle)
                    }
                    episodes += findOrbEpisodes(
                        technique: technique, factor1: f1, factor2: f2,
                        kind: .aspectProgToProg(aspect), deviation: deviation,
                        startJD: startJD, endJD: endJD, stepSize: stepSize, maxOrb: maxOrb
                    )
                }
            }
        }
        return episodes
    }

    private func findParallelEpisodesProgToProg(
        technique: ProgressiveCalendarTechnique, factors: [Factors],
        startJD: Double, endJD: Double, stepSize: Double, provider: TechniqueProvider, maxOrb: Double
    ) -> [ProgressiveOrbEpisode] {
        guard factors.count > 1 else { return [] }
        var episodes: [ProgressiveOrbEpisode] = []
        for i in 0..<factors.count {
            for j in (i + 1)..<factors.count {
                let f1 = factors[i], f2 = factors[j]
                let deviation: (Double) -> Double = { jd in
                    abs(provider.declination(f1, jd)) - abs(provider.declination(f2, jd))
                }
                let raw = findOrbEpisodes(
                    technique: technique, factor1: f1, factor2: f2,
                    kind: .parallelProgToProg, deviation: deviation,
                    startJD: startJD, endJD: endJD, stepSize: stepSize, maxOrb: maxOrb
                )
                episodes += raw.map { episode in
                    let isContra = (provider.declination(f1, episode.exactJD) >= 0) != (provider.declination(f2, episode.exactJD) >= 0)
                    guard isContra else { return episode }
                    return ProgressiveOrbEpisode(
                        technique: episode.technique, factor1: episode.factor1, factor2: episode.factor2,
                        kind: .contraParallelProgToProg, enterJD: episode.enterJD, exactJD: episode.exactJD,
                        exitJD: episode.exitJD, minOrb: episode.minOrb, maxOrb: episode.maxOrb,
                        becomesExact: episode.becomesExact
                    )
                }
            }
        }
        return episodes
    }

    // MARK: - Generic orb episode builder

    /// Builds orb episodes from a signed `deviation` function of Julian Day: the episode is
    /// in orb while `|deviation| <= maxOrb`. Reused for aspects and parallels alike — only
    /// `deviation` differs between the two.
    ///
    /// If the episode's interior never reaches an exact/exact-magnitude crossing (`deviation`
    /// never hits exactly 0 — e.g. a station reverses the approach before it gets there), the
    /// closer of the episode's two boundary moments is used as an approximate `exactJD`
    /// instead of solving for the true closest approach. This is a deliberate simplification.
    private func findOrbEpisodes(
        technique: ProgressiveCalendarTechnique, factor1: Factors, factor2: Factors,
        kind: ProgressiveOrbEpisodeKind, deviation: @escaping (Double) -> Double,
        startJD: Double, endJD: Double, stepSize: Double, maxOrb: Double
    ) -> [ProgressiveOrbEpisode] {
        let guardFn: (Double, Double) -> Bool = { abs($0) + abs($1) < Self.WRAPAROUND_GUARD_SUM }

        let exactCrossings = ZeroCrossingScanner.scan(
            startJD: startJD, endJD: endJD, stepSize: { _ in stepSize },
            tolerance: Self.ZERO_CROSSING_TOLERANCE, isPlausibleCrossing: guardFn, f: deviation
        )
        let boundaryCrossings = ZeroCrossingScanner.scan(
            startJD: startJD, endJD: endJD, stepSize: { _ in stepSize },
            tolerance: Self.ZERO_CROSSING_TOLERANCE, isPlausibleCrossing: guardFn,
            f: { jd in abs(deviation(jd)) - maxOrb }
        )

        let startsInOrb = abs(deviation(startJD)) <= maxOrb
        guard !boundaryCrossings.isEmpty || startsInOrb else { return [] }

        var episodes: [ProgressiveOrbEpisode] = []
        var hasOpenEpisode = startsInOrb
        var pendingEnter: Double? = nil

        func closeEpisode(enterJD: Double?, exitJD: Double?) {
            let lo = enterJD ?? startJD
            let hi = exitJD ?? endJD
            let genuineExact = exactCrossings.first { $0 >= lo && $0 <= hi }
            let exact = genuineExact ?? closestApproachJD(lo: lo, hi: hi, stepSize: stepSize, deviation: deviation)
            episodes.append(ProgressiveOrbEpisode(
                technique: technique, factor1: factor1, factor2: factor2, kind: kind,
                enterJD: enterJD, exactJD: exact, exitJD: exitJD,
                minOrb: abs(deviation(exact)), maxOrb: maxOrb, becomesExact: genuineExact != nil
            ))
        }

        for crossingJD in boundaryCrossings {
            if hasOpenEpisode {
                closeEpisode(enterJD: pendingEnter, exitJD: crossingJD)
                hasOpenEpisode = false
                pendingEnter = nil
            } else {
                pendingEnter = crossingJD
                hasOpenEpisode = true
            }
        }
        if hasOpenEpisode {
            closeEpisode(enterJD: pendingEnter, exitJD: nil)
        }

        return episodes
    }

    /// Approximates the moment of closest approach within `[lo, hi]` when `deviation` never
    /// actually reaches zero there (e.g. a station reverses the approach before the aspect
    /// becomes exact) — a local extremum of `|deviation|` is where its derivative crosses
    /// zero, found here via numerical differentiation and the same zero-crossing scanner used
    /// everywhere else, since `deviation` has no closed-form derivative available.
    ///
    /// For a genuine episode (both `lo` and `hi` are real orb-boundary crossings, so
    /// `|deviation|` is `maxOrb` at both ends), continuity guarantees an interior minimum
    /// exists and this always finds it. When one end is a scan-range boundary rather than a
    /// real orb crossing (`enterJD`/`exitJD` was nil), `deviation` may instead be monotonic
    /// across the whole visible window (the true closest approach lies outside the scanned
    /// range) — then no extremum exists here, and picking the closer endpoint is the best
    /// available answer.
    private func closestApproachJD(lo: Double, hi: Double, stepSize: Double, deviation: (Double) -> Double) -> Double {
        guard hi > lo else { return lo }
        let h = min(Self.ZERO_CROSSING_TOLERANCE * 1000, (hi - lo) / 4.0)
        func derivative(_ jd: Double) -> Double {
            let a = max(lo, jd - h), b = min(hi, jd + h)
            guard b > a else { return 0 }
            return (deviation(b) - deviation(a)) / (b - a)
        }
        let extrema = ZeroCrossingScanner.scan(
            startJD: lo, endJD: hi, stepSize: { _ in stepSize }, tolerance: Self.ZERO_CROSSING_TOLERANCE, f: derivative
        )
        if let closest = extrema.min(by: { abs(deviation($0)) < abs(deviation($1)) }) {
            return closest
        }
        return abs(deviation(lo)) <= abs(deviation(hi)) ? lo : hi
    }

    // MARK: - Radix lookups

    private func radixLongitudes(for factors: [Factors]) -> [(Factors, Double)] {
        factors.compactMap { factor in
            radixChart.Coordinates[factor]?.ecliptical.first.map { (factor, $0.mainPos) }
        }
    }

    private func radixDeclinations(for factors: [Factors]) -> [(Factors, Double)] {
        factors.compactMap { factor in
            radixChart.Coordinates[factor]?.equatorial.first.map { (factor, $0.deviation) }
        }
    }

    // MARK: - Step sizing

    /// Coarse scan step, in days of real time, for a technique and the factors involved in a
    /// particular scan. These are initial heuristics — the Moon is fast even in transits, and
    /// secondary/symbolic directions compress a lifetime into roughly a hundred days, so their
    /// internal positions barely move per real-world day.
    private static func stepSizeInDays(technique: ProgressiveCalendarTechnique, factors: [Factors]) -> Double {
        switch technique {
        case .transit:
            if factors.contains(.moon) { return 0.1 }
            let inner: Set<Factors> = [.sun, .mercury, .venus, .mars]
            if factors.contains(where: inner.contains) { return 0.5 }
            return 2.0
        case .secondaryDirection:
            if factors.contains(.moon) { return 5.0 }
            return 30.0
        case .symbolicDirection:
            return 60.0
        }
    }

    // MARK: - Low-level ephemeris helpers

    private func calcLongitude(_ factor: Factors, _ jd: Double) -> Double {
        seWrapper.calculateFactorPosition(julianDay: jd, factor: factor.seId, flags: 2)?.mainPos ?? 0.0
    }

    private func calcLongitudeSpeed(_ factor: Factors, _ jd: Double) -> Double {
        seWrapper.calculateFactorPosition(julianDay: jd, factor: factor.seId, flags: 2 + 256)?.mainPosSpeed ?? 0.0
    }

    private func calcDeclination(_ factor: Factors, _ jd: Double) -> Double {
        seWrapper.calculateFactorPosition(julianDay: jd, factor: factor.seId, flags: 2 + 2048)?.deviation ?? 0.0
    }

    private func calcDeclinationSpeed(_ factor: Factors, _ jd: Double) -> Double {
        seWrapper.calculateFactorPosition(julianDay: jd, factor: factor.seId, flags: 2 + 256 + 2048)?.deviationSpeed ?? 0.0
    }

    private func obliquity(at jd: Double) -> Double {
        seWrapper.calculateFactorPosition(julianDay: jd, factor: -1, flags: 2)?.mainPos ?? radixChart.Obliquity
    }

    // MARK: - Angular helpers

    /// Signed deviation from an exact aspect, in the range roughly (−180, 180], mirroring
    /// `PreNatalOrchestrator`'s `dist()`: changes sign exactly when the aspect is exact.
    private static func signedAspectDeviation(_ lon1: Double, _ lon2: Double, aspectAngle: Double) -> Double {
        var diff = (lon1 - lon2).truncatingRemainder(dividingBy: 360.0)
        if diff < 0 { diff += 360.0 }
        let d1 = diff - aspectAngle
        let d2 = diff - (360.0 - aspectAngle)
        return abs(d1) <= abs(d2) ? d1 : d2
    }

    /// Signed shortest angular distance from `lon1` to `lon2`, in (−180, 180].
    private static func signedDistance(_ lon1: Double, _ lon2: Double) -> Double {
        signedAspectDeviation(lon1, lon2, aspectAngle: 0.0)
    }

    // MARK: - Event construction

    private func makeEvent(
        technique: ProgressiveCalendarTechnique, jd: Double, kind: ProgressiveCalendarEventKind, longitude: Double
    ) -> ProgressiveCalendarEvent {
        ProgressiveCalendarEvent(technique: technique, jd: jd, dateTxt: dateTimeStr(jd), kind: kind, longitude: longitude)
    }

    private func dateTimeStr(_ jd: Double) -> String {
        let dt = seWrapper.dateFromJulianDay(jd)
        let sec = min(dt.Time.Second, 59)
        return String(format: "%04d/%02d/%02d %02d:%02d:%02d",
                      dt.Date.Year, dt.Date.Month, dt.Date.Day,
                      dt.Time.Hour, dt.Time.Minute, sec)
    }
}
