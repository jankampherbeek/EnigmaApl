// ZeroCrossingScanner.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Generic zero-crossing scanner for Progressive Calendar event finding: locates moments
/// in time where a signed function of Julian Day changes sign, refined to a tight tolerance
/// by bisection.
///
/// The scanner does not know what the function *means* — the same scanner locates an aspect
/// becoming exact (`f` = signed angular deviation from the aspect angle), a retrograde/direct
/// station (`f` = longitude speed), an OOB entry (`f` = |declination| − obliquity), or a
/// declination extreme (`f` = declination speed, since an extreme is where the derivative
/// crosses zero) — only `f` changes between use cases. This generalizes the coarse-step +
/// bisection pattern used by `PreNatalOrchestrator`.
struct ZeroCrossingScanner {

    private init() {}

    /// Scans `[startJD, endJD]` for Julian Days where `f` changes sign.
    /// - Parameters:
    ///   - stepSize: coarse sampling step, in days, as a function of the current Julian Day.
    ///     Allows adaptive stepping — e.g. much coarser for slow-moving secondary/symbolic
    ///     directions than for transits.
    ///   - tolerance: bisection stops refining once the bracketing interval is narrower than
    ///     this, in days. Also used as a floor for `stepSize`, to guarantee termination.
    ///   - isPlausibleCrossing: extra guard evaluated on a detected sign change, given the
    ///     function values at both ends of the coarse step. Used to reject spurious crossings
    ///     caused by circular wraparound — e.g. an angular deviation jumping from +179° to
    ///     −179° is a sign change but not a real crossing through zero.
    ///   - f: the signed function of Julian Day being scanned.
    /// - Returns: the Julian Days of all detected zero crossings, in ascending order.
    static func scan(
        startJD: Double,
        endJD: Double,
        stepSize: (Double) -> Double,
        tolerance: Double = 1e-7,
        isPlausibleCrossing: (Double, Double) -> Bool = { _, _ in true },
        f: (Double) -> Double
    ) -> [Double] {
        guard startJD < endJD else { return [] }

        var crossings: [Double] = []
        var curJD = startJD
        var curF = f(curJD)

        while curJD < endJD {
            let step = max(stepSize(curJD), tolerance)
            let nxtJD = min(curJD + step, endJD)
            let nxtF = f(nxtJD)

            if curF * nxtF < 0 && isPlausibleCrossing(curF, nxtF) {
                crossings.append(bisect(jdA: curJD, jdB: nxtJD, fA: curF, fB: nxtF, tolerance: tolerance, f: f))
            }

            curJD = nxtJD
            curF = nxtF
        }

        return crossings
    }

    // MARK: - Private helpers

    private static func bisect(
        jdA: Double, jdB: Double, fA: Double, fB: Double, tolerance: Double, f: (Double) -> Double
    ) -> Double {
        var lo = jdA, hi = jdB
        var loF = fA
        while hi - lo > tolerance {
            let mid = (lo + hi) / 2.0
            let midF = f(mid)
            if loF * midF <= 0 {
                hi = mid
            } else {
                lo = mid
                loF = midF
            }
        }
        return (lo + hi) / 2.0
    }
}
