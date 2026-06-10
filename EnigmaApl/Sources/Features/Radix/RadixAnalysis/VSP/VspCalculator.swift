// VspCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Core astronomical calculations for Venus Star Point.
/// Based on Jean Meeus, Astronomical Algorithms, 2nd ed., pp. 249–251.
struct VspCalculator {

    private init() {}

    // MARK: - Venus conjunction constants (Meeus p. 250)

    private static let infA:  Double = 2_451_996.706
    private static let infB:  Double = 583.921361
    private static let infM0: Double = 82.7311
    private static let infM1: Double = 215.513058

    private static let supA:  Double = 2_451_704.746
    private static let supB:  Double = 583.921361
    private static let supM0: Double = 154.9745
    private static let supM1: Double = 215.513058

    private static let yearLength:       Double = 365.25
    private static let maxVenusPeriod:   Double = 584.0
    private static let minVenusPeriod:   Double = 583.0
    private static let jdTolerance:      Double = 0.1      // ~2.4 hours
    private static let repeatCount:      Int    = 14

    private static let seSun:            Int    = 0
    private static let seVenus:          Int    = 3
    private static let seFlags:          Int    = 2        // SEFLG_SWIEPH
    private static let searchMargin:     Double = 1e-6     // < 1 second of arc
    private static let minInterval:      Double = 1e-12
    private static let maxIterations:    Int    = 1000

    // MARK: - Public entry point

    /// Calculates the five Venus Star Point JDs and phenomena surrounding `birthJd`.
    static func calculateVspJds(birthJd: Double, seWrapper: SEWrapper) -> [(Double, VenusPhenomena)] {
        var found: [(Double, VenusPhenomena)] = []

        var lastInferior = birthJd - 2 * maxVenusPeriod
        var lastSuperior = lastInferior

        for _ in 0..<repeatCount {
            let phenom = phenomenonJd(after: lastInferior, type: .inferiorConjunction, seWrapper: seWrapper)
            lastInferior = phenom.0
            found.append(phenom)
        }
        for _ in 0..<repeatCount {
            let phenom = phenomenonJd(after: lastSuperior, type: .superiorConjunction, seWrapper: seWrapper)
            lastSuperior = phenom.0
            found.append(phenom)
        }

        found.sort { $0.0 < $1.0 }
        found = removeDuplicates(found)
        return selectSubset(from: found, birthJd: birthJd)
    }

    // MARK: - Year fraction (Meeus p. 249)

    private static func yearFraction(year: Int, jd: Double, jdNewYear: Double) -> Double {
        Double(year) + (jd - jdNewYear) / yearLength
    }

    // MARK: - Estimated conjunction date (Meeus p. 250–251)

    private static func estimatedConjunctionDate(yearFrac: Double, type: VenusPhenomena) -> Double {
        let a  = type == .inferiorConjunction ? infA  : supA
        let b  = type == .inferiorConjunction ? infB  : supB
        let m0 = type == .inferiorConjunction ? infM0 : supM0
        let m1 = type == .inferiorConjunction ? infM1 : supM1

        let k     = ((365.2425 * yearFrac + 1_721_060 - a) / b).rounded()
        let jde0  = a + k * b
        let m     = m0 + k * m1
        let t     = (jde0 - 2_451_545.0) / 36_525.0
        let corr  = type == .inferiorConjunction
            ? correctionInferior(t: t, m: m)
            : correctionSuperior(t: t, m: m)
        return jde0 + corr
    }

    private static func correctionInferior(t: Double, m: Double) -> Double {
        let r = m * .pi / 180.0
        var c = -0.0096 + 0.0002 * t - 0.00001 * t * t
        c += (2.0009  - 0.0033 * t - 0.00001 * t * t) * sin(r)
        c += (0.5980  - 0.0104 * t + 0.00001 * t * t) * cos(r)
        c += (0.0967  - 0.0018 * t - 0.00003 * t * t) * sin(2 * r)
        c += (0.0913  + 0.0009 * t - 0.00002 * t * t) * cos(2 * r)
        c += (0.0046  - 0.0002 * t)                   * sin(3 * r)
        c += (0.0079  + 0.0001 * t)                   * cos(3 * r)
        return c
    }

    private static func correctionSuperior(t: Double, m: Double) -> Double {
        let r = m * .pi / 180.0
        var c =  0.0099 - 0.0002 * t - 0.00001 * t * t
        c += ( 4.1991  - 0.0121 * t - 0.00003 * t * t) * sin(r)
        c += (-0.6095  + 0.0102 * t - 0.00002 * t * t) * cos(r)
        c += ( 0.2500  - 0.0028 * t - 0.00003 * t * t) * sin(2 * r)
        c += ( 0.0063  - 0.0025 * t - 0.00002 * t * t) * cos(2 * r)
        c += ( 0.0232  - 0.0005 * t - 0.00001 * t * t) * sin(3 * r)
        c += ( 0.0031  + 0.0004 * t)                   * cos(3 * r)
        return c
    }

    // MARK: - Exact conjunction date (binary search)

    private static func exactConjunctionDate(estimated: Double, type: VenusPhenomena, seWrapper: SEWrapper) -> Double {
        findExact(low: estimated - 1, high: estimated + 1, type: type, seWrapper: seWrapper)
    }

    private static func findExact(low: Double, high: Double, type: VenusPhenomena, seWrapper: SEWrapper) -> Double {
        var lo = low
        var hi = high
        var bestJd   = (lo + hi) / 2.0
        var bestDiff = Double.greatestFiniteMagnitude

        for _ in 0..<maxIterations {
            guard abs(hi - lo) > minInterval else { break }
            let mid  = (lo + hi) / 2.0
            let diff = sunMinusVenus(jd: mid, seWrapper: seWrapper)

            if abs(diff) < abs(bestDiff) { bestDiff = diff; bestJd = mid }
            if abs(diff) <= searchMargin { return mid }

            if diff > 0 {
                if type == .inferiorConjunction { hi = mid } else { lo = mid }
            } else {
                if type == .inferiorConjunction { lo = mid } else { hi = mid }
            }
        }
        return bestJd
    }

    private static func sunMinusVenus(jd: Double, seWrapper: SEWrapper) -> Double {
        let sun   = seWrapper.calculateFactorPosition(julianDay: jd, factor: seSun,   flags: seFlags)?.mainPos ?? 0.0
        let venus = seWrapper.calculateFactorPosition(julianDay: jd, factor: seVenus, flags: seFlags)?.mainPos ?? 0.0
        var diff  = sun - venus
        while diff >  180 { diff -= 360 }
        while diff < -180 { diff += 360 }
        return diff
    }

    // MARK: - Helpers

    private static func phenomenonJd(after lastJd: Double, type: VenusPhenomena, seWrapper: SEWrapper) -> (Double, VenusPhenomena) {
        let nextJd     = lastJd + minVenusPeriod
        let dt         = seWrapper.dateFromJulianDay(nextJd)
        let year       = dt.Date.Year
        let jdNewYear  = seWrapper.julianDay(
            date: AstronomicalDate(Year: year, Month: 1, Day: 1),
            time: AstronomicalTime(HourDecimal: 0.0)
        )
        let yearFrac   = yearFraction(year: year, jd: nextJd, jdNewYear: jdNewYear)
        let estimated  = estimatedConjunctionDate(yearFrac: yearFrac, type: type)
        let exact      = exactConjunctionDate(estimated: estimated, type: type, seWrapper: seWrapper)
        return (exact, type)
    }

    private static func removeDuplicates(_ list: [(Double, VenusPhenomena)]) -> [(Double, VenusPhenomena)] {
        guard list.count > 1 else { return list }
        var result = [list[0]]
        for i in 1..<list.count where abs(list[i].0 - list[i - 1].0) > jdTolerance {
            result.append(list[i])
        }
        return result
    }

    private static func selectSubset(from list: [(Double, VenusPhenomena)], birthJd: Double) -> [(Double, VenusPhenomena)] {
        guard !list.isEmpty else { return [] }
        var lastBefore = -1
        for (i, item) in list.enumerated() {
            if item.0 < birthJd { lastBefore = i } else { break }
        }
        let start = max(0, lastBefore == -1 ? 0 : lastBefore - 2)
        let end   = min(list.count, start + 5)
        return Array(list[start..<end])
    }
}
