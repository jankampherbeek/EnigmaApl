// PreNatalOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Domain types

enum PreNatalMomentKind: Sendable {
    case solarEclipse
    case lunarEclipse
    case ingress(factor: Factors, sign: Signs)
    case direct(factor: Factors)
    case retrograde(factor: Factors)
    case aspect(kind: Aspects, factor1: Factors, factor2: Factors)
}

struct PreNatalMoment: Identifiable, Sendable {
    let id = UUID()
    let prenatalJD: Double
    let actualJD: Double
    let prenatalDateTxt: String
    let actualDateTxt: String
    let kind: PreNatalMomentKind
    let longitude1: Double
    let longitude2: Double?
}

// MARK: - Orchestrator

struct PreNatalOrchestrator: Sendable {
    private static let TROPICAL_YEAR = 365.242199074
    private static let CONCEPTION_PERIOD = 273.217
    // 70 years of life per 273.217 days of gestation, scaled by tropical year
    private static let CONVERSION_FACTOR = TROPICAL_YEAR * (70.0 / CONCEPTION_PERIOD)
    private static let MARGIN_BEFORE_CONCEPTION = 30.0
    // 390.31 prenatal days ≈ 100 years of actual life; end of search window matches C# reference
    private static let MAX_LIFETIME_IN_PRENATAL_DAYS = 390.31

    static let defaultFactors: [Factors] = [
        .sun, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto
    ]

    static let defaultAspects: [Aspects] = [
        .conjunction
    ]

    static let selectableFactors: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto,
        .northNode, .chiron, .pholus, .ceres, .pallas, .juno, .vesta,
        .apogeeMean, .apogeeCorrected,
        .cupidoUra, .hadesUra, .zeusUra, .kronosUra, .apollonUra, .admetosUra, .vulcanusUra, .poseidonUra,
        .isis, .eris, .nessus, .huya, .varuna, .ixion, .quaoar, .haumea, .orcus, .makemake, .sedna,
        .hygieia, .astraea
    ]

    func calculate(
        natalJD: Double,
        conceptionJD: Double,
        selectedFactors: [Factors],
        selectedAspects: [Aspects],
        useAspects: Bool,
        useEclipses: Bool,
        useIngresses: Bool,
        useRetroDirect: Bool
    ) -> ([PreNatalMoment], Double) {
        let seWrapper = SEWrapper()
        let startJD = conceptionJD - Self.MARGIN_BEFORE_CONCEPTION
        // End matches C# _endOfPeriodJd = baseConceptionJD + 390.31 = natalJD + 117.09 days.
        // This covers prenatal events mapping to life years 0–100, not just 0–70.
        let baseConceptionJD = natalJD - Self.CONCEPTION_PERIOD
        let endJD = baseConceptionJD + Self.MAX_LIFETIME_IN_PRENATAL_DAYS

        var moments: [PreNatalMoment] = []

        if useEclipses {
            moments += findEclipses(startJD: startJD, endJD: endJD,
                                    conceptionJD: conceptionJD, natalJD: natalJD, se: seWrapper)
        }
        if useIngresses {
            moments += findIngresses(factors: selectedFactors, startJD: startJD, endJD: endJD,
                                     conceptionJD: conceptionJD, natalJD: natalJD, se: seWrapper)
        }
        if useRetroDirect {
            moments += findRetroDirectMoments(factors: selectedFactors, startJD: startJD, endJD: endJD,
                                              conceptionJD: conceptionJD, natalJD: natalJD, se: seWrapper)
        }
        if useAspects {
            moments += findAspects(factors: selectedFactors, aspects: selectedAspects,
                                   startJD: startJD, endJD: endJD,
                                   conceptionJD: conceptionJD, natalJD: natalJD, se: seWrapper)
        }

        return (moments.sorted { $0.prenatalJD < $1.prenatalJD }, conceptionJD)
    }

    // MARK: - Eclipses

    private func findEclipses(startJD: Double, endJD: Double,
                               conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        var result: [PreNatalMoment] = []

        var runJD = startJD
        while runJD < endJD {
            guard let eclJD = se.nextSolarEclipse(afterJD: runJD) else { break }
            if eclJD > endJD { break }
            let lon = calcLon(.sun, eclJD, se)
            result.append(make(prenatalJD: eclJD, conceptionJD: conceptionJD, natalJD: natalJD,
                               kind: .solarEclipse, lon1: lon, lon2: nil, se: se))
            runJD = eclJD + 1.0
        }

        runJD = startJD
        while runJD < endJD {
            guard let eclJD = se.nextLunarEclipse(afterJD: runJD) else { break }
            if eclJD > endJD { break }
            // C# reference uses the Sun's longitude for both solar and lunar eclipses.
            let lon = calcLon(.sun, eclJD, se)
            result.append(make(prenatalJD: eclJD, conceptionJD: conceptionJD, natalJD: natalJD,
                               kind: .lunarEclipse, lon1: lon, lon2: nil, se: se))
            runJD = eclJD + 1.0
        }

        return result
    }

    // MARK: - Ingresses

    private func findIngresses(factors: [Factors], startJD: Double, endJD: Double,
                                conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        factors.flatMap {
            findIngressesFor(factor: $0, startJD: startJD, endJD: endJD,
                             conceptionJD: conceptionJD, natalJD: natalJD, se: se)
        }
    }

    private func findIngressesFor(factor: Factors, startJD: Double, endJD: Double,
                                   conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        let margin = 1e-6
        var result: [PreNatalMoment] = []

        func search(jdA: Double, jdB: Double, lonA: Double, lonB: Double, step: Double) {
            if step < margin {
                let signIdx = Int(lonB / 30.0)
                let sign = Signs(rawValue: signIdx + 1) ?? .Aries
                result.append(make(prenatalJD: jdB, conceptionJD: conceptionJD, natalJD: natalJD,
                                   kind: .ingress(factor: factor, sign: sign), lon1: lonB, lon2: nil, se: se))
                return
            }
            let fineStep = step / 10.0
            var curJD = jdA
            var curLon = lonA
            while curJD < jdB {
                let nxtJD = min(curJD + fineStep, jdB)
                let nxtLon = calcLon(factor, nxtJD, se)
                if Int(curLon / 30.0) != Int(nxtLon / 30.0) {
                    search(jdA: curJD, jdB: nxtJD, lonA: curLon, lonB: nxtLon, step: fineStep)
                }
                curJD = nxtJD
                curLon = nxtLon
            }
        }

        var curJD = startJD
        var curLon = calcLon(factor, curJD, se)
        while curJD < endJD {
            let nxtJD = min(curJD + 1.0, endJD)
            let nxtLon = calcLon(factor, nxtJD, se)
            if Int(curLon / 30.0) != Int(nxtLon / 30.0) {
                search(jdA: curJD, jdB: nxtJD, lonA: curLon, lonB: nxtLon, step: 1.0)
            }
            curJD = nxtJD
            curLon = nxtLon
        }

        return result
    }

    // MARK: - Retro/Direct

    private func findRetroDirectMoments(factors: [Factors], startJD: Double, endJD: Double,
                                         conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        factors
            .filter { $0 != .sun && $0 != .moon }
            .flatMap {
                findRetroDirectFor(factor: $0, startJD: startJD, endJD: endJD,
                                   conceptionJD: conceptionJD, natalJD: natalJD, se: se)
            }
    }

    private func findRetroDirectFor(factor: Factors, startJD: Double, endJD: Double,
                                     conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        let tolerance = 1e-7
        var result: [PreNatalMoment] = []
        var curJD = startJD
        var curSpeed = calcSpeed(factor, curJD, se)

        while curJD < endJD {
            let nxtJD = min(curJD + 1.0, endJD)
            let nxtSpeed = calcSpeed(factor, nxtJD, se)

            if curSpeed * nxtSpeed < 0 {
                var lo = curJD, hi = nxtJD
                var loSpeed = curSpeed
                while hi - lo > tolerance {
                    let mid = (lo + hi) / 2.0
                    let midSpeed = calcSpeed(factor, mid, se)
                    if loSpeed * midSpeed <= 0 { hi = mid } else { lo = mid; loSpeed = midSpeed }
                }
                let exactJD = (lo + hi) / 2.0
                let lon = calcLon(factor, exactJD, se)
                let kind: PreNatalMomentKind = curSpeed > 0 ? .retrograde(factor: factor) : .direct(factor: factor)
                result.append(make(prenatalJD: exactJD, conceptionJD: conceptionJD, natalJD: natalJD,
                                   kind: kind, lon1: lon, lon2: nil, se: se))
            }

            curJD = nxtJD
            curSpeed = nxtSpeed
        }

        return result
    }

    // MARK: - Aspects

    private func findAspects(factors: [Factors], aspects: [Aspects],
                              startJD: Double, endJD: Double,
                              conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        var result: [PreNatalMoment] = []
        for i in 0..<factors.count {
            for j in (i + 1)..<factors.count {
                result += findAspectsForPair(f1: factors[i], f2: factors[j], aspects: aspects,
                                             startJD: startJD, endJD: endJD,
                                             conceptionJD: conceptionJD, natalJD: natalJD, se: se)
            }
        }
        return result
    }

    private func findAspectsForPair(f1: Factors, f2: Factors, aspects: [Aspects],
                                     startJD: Double, endJD: Double,
                                     conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        let step = stepSize(f1, f2)
        var result: [PreNatalMoment] = []
        var curJD = startJD
        var lon1 = calcLon(f1, curJD, se)
        var lon2 = calcLon(f2, curJD, se)

        while curJD < endJD {
            let nxtJD = min(curJD + step, endJD)
            let nLon1 = calcLon(f1, nxtJD, se)
            let nLon2 = calcLon(f2, nxtJD, se)

            for aspect in aspects {
                let dCur = dist(lon1, lon2, aspect)
                let dNxt = dist(nLon1, nLon2, aspect)
                if dCur * dNxt < 0 && (abs(dCur) + abs(dNxt)) < 90.0 {
                    result += refineAspect(f1: f1, f2: f2, aspect: aspect,
                                          jdA: curJD, jdB: nxtJD,
                                          lon1A: lon1, lon2A: lon2, lon1B: nLon1, lon2B: nLon2,
                                          conceptionJD: conceptionJD, natalJD: natalJD, se: se)
                }
            }

            curJD = nxtJD
            lon1 = nLon1
            lon2 = nLon2
        }

        return result
    }

    private func refineAspect(f1: Factors, f2: Factors, aspect: Aspects,
                               jdA: Double, jdB: Double,
                               lon1A: Double, lon2A: Double, lon1B: Double, lon2B: Double,
                               conceptionJD: Double, natalJD: Double, se: SEWrapper) -> [PreNatalMoment] {
        if jdB - jdA < 1e-7 {
            return [make(prenatalJD: (jdA + jdB) / 2.0, conceptionJD: conceptionJD, natalJD: natalJD,
                         kind: .aspect(kind: aspect, factor1: f1, factor2: f2),
                         lon1: lon1A, lon2: lon2A, se: se)]
        }
        let mid = (jdA + jdB) / 2.0
        let lon1M = calcLon(f1, mid, se)
        let lon2M = calcLon(f2, mid, se)
        let dA = dist(lon1A, lon2A, aspect)
        let dM = dist(lon1M, lon2M, aspect)
        if dA * dM <= 0 {
            return refineAspect(f1: f1, f2: f2, aspect: aspect,
                                jdA: jdA, jdB: mid, lon1A: lon1A, lon2A: lon2A, lon1B: lon1M, lon2B: lon2M,
                                conceptionJD: conceptionJD, natalJD: natalJD, se: se)
        } else {
            return refineAspect(f1: f1, f2: f2, aspect: aspect,
                                jdA: mid, jdB: jdB, lon1A: lon1M, lon2A: lon2M, lon1B: lon1B, lon2B: lon2B,
                                conceptionJD: conceptionJD, natalJD: natalJD, se: se)
        }
    }

    // MARK: - Low-level helpers

    private func calcLon(_ factor: Factors, _ jd: Double, _ se: SEWrapper) -> Double {
        se.calculateFactorPosition(julianDay: jd, factor: factor.seId, flags: 2)?.mainPos ?? 0
    }

    private func calcSpeed(_ factor: Factors, _ jd: Double, _ se: SEWrapper) -> Double {
        se.calculateFactorPosition(julianDay: jd, factor: factor.seId, flags: 2 + 256)?.mainPosSpeed ?? 0
    }

    // Returns a signed value that changes sign exactly when the aspect is exact.
    private func dist(_ lon1: Double, _ lon2: Double, _ aspect: Aspects) -> Double {
        var diff = (lon1 - lon2).truncatingRemainder(dividingBy: 360.0)
        if diff < 0 { diff += 360.0 }
        let angle = aspect.angle
        let d1 = diff - angle
        let d2 = diff - (360.0 - angle)
        return abs(d1) <= abs(d2) ? d1 : d2
    }

    private func stepSize(_ f1: Factors, _ f2: Factors) -> Double {
        if f1 == .moon || f2 == .moon { return 0.1 }
        let inners: Set<Factors> = [.sun, .mercury, .venus, .mars]
        if inners.contains(f1) || inners.contains(f2) { return 0.5 }
        return 1.0
    }

    private func make(prenatalJD: Double, conceptionJD: Double, natalJD: Double,
                      kind: PreNatalMomentKind, lon1: Double, lon2: Double?,
                      se: SEWrapper) -> PreNatalMoment {
        let actualJD = toActual(prenatalJD, conception: conceptionJD, natal: natalJD)
        return PreNatalMoment(
            prenatalJD: prenatalJD,
            actualJD: actualJD,
            prenatalDateTxt: dateTimeStr(prenatalJD, se: se),
            actualDateTxt: dateStr(actualJD, se: se),
            kind: kind,
            longitude1: lon1,
            longitude2: lon2
        )
    }

    private func toActual(_ prenatalJD: Double, conception: Double, natal: Double) -> Double {
        (prenatalJD - conception) * Self.CONVERSION_FACTOR + natal
    }

    private func dateStr(_ jd: Double, se: SEWrapper) -> String {
        let dt = se.dateFromJulianDay(jd)
        return String(format: "%04d/%02d/%02d", dt.Date.Year, dt.Date.Month, dt.Date.Day)
    }

    private func dateTimeStr(_ jd: Double, se: SEWrapper) -> String {
        let dt = se.dateFromJulianDay(jd)
        let sec = min(dt.Time.Second, 59)
        return String(format: "%04d/%02d/%02d %02d:%02d:%02d",
                      dt.Date.Year, dt.Date.Month, dt.Date.Day,
                      dt.Time.Hour, dt.Time.Minute, sec)
    }
}
