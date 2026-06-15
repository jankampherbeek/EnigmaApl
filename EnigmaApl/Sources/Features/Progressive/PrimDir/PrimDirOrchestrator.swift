// PrimDirOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

private typealias CA = PrimDirCalcAssist

struct PrimDirHit {
    let julianDay: Double
    let dateTxt: String
    let significator: Factors
    let promissor: Factors
    let aspect: Aspects
}

// MARK: - Orchestrator

struct PrimDirOrchestrator {
    private let TROPICAL_YEAR = 365.242199074
    private let NAIBOD = 0.985647358006

    /// Calculate primary direction hits for the given chart and date range.
    func calculate(
        chart: FullChart,
        geoLat: Double,
        natalJD: Double,
        startJD: Double,
        endJD: Double,
        config: PrimaryDirectionsConfig
    ) -> [PrimDirHit] {
        let seWrapper = SEWrapper()
        let specBase = buildSpecBase(chart: chart, geoLat: geoLat)
        var hits: [PrimDirHit] = []

        let promissors   = config.promissors.filter   { chart.Coordinates[$0] != nil }
        let significators = config.significators.filter { chart.Coordinates[$0] != nil }

        for promissor in promissors {
            for significator in significators {
                guard promissor != significator else { continue }
                for aspect in [Aspects.conjunction, Aspects.opposition] {
                    let arc = calcArc(
                        chart: chart, specBase: specBase, config: config,
                        promissor: promissor, significator: significator, aspect: aspect
                    )
                    guard !arc.isNaN else { continue }
                    let jd = jdForEvent(natalJD: natalJD, arc: arc, key: config.timeKey, seWrapper: seWrapper)
                    if jd > startJD && jd <= endJD {
                        hits.append(PrimDirHit(
                            julianDay: jd,
                            dateTxt: jdToDateString(jd, seWrapper: seWrapper),
                            significator: significator,
                            promissor: promissor,
                            aspect: aspect
                        ))
                    }
                }
            }
        }

        return hits.sorted { $0.julianDay < $1.julianDay }
    }

    // MARK: - Arc dispatch

    private func calcArc(
        chart: FullChart, specBase: SpecBase, config: PrimaryDirectionsConfig,
        promissor: Factors, significator: Factors, aspect: Aspects
    ) -> Double {
        guard let promPos = chart.Coordinates[promissor],
              let signPos = chart.Coordinates[significator] else { return .nan }
        let isOpp = (aspect == .opposition)
        switch config.method {
        case .placidus:
            let promSpec = buildPlacSpec(pos: promPos, specBase: specBase, config: config, isOpp: isOpp)
            let signSpec = buildPlacSpec(pos: signPos, specBase: specBase, config: config, isOpp: false)
            return placidusArc(prom: promSpec, sign: signSpec, specBase: specBase)
        case .regiomontanus:
            let promSpec = buildRegSpec(pos: promPos, specBase: specBase, config: config, isOpp: isOpp)
            let signSpec = buildRegSpec(pos: signPos, specBase: specBase, config: config, isOpp: false)
            return regiomontanusArc(prom: promSpec, sign: signSpec)
        }
    }

    // MARK: - SpecBase

    private func buildSpecBase(chart: FullChart, geoLat: Double) -> SpecBase {
        let raMc = chart.HousePositions.midheaven.rightAscension
        let raIc = raMc <= 180 ? raMc + 180 : raMc - 180
        var oaAsc = raMc + 90
        if oaAsc >= 360 { oaAsc -= 360 }
        return SpecBase(
            raMc: raMc,
            raIc: raIc,
            lonMc: chart.HousePositions.midheaven.longitude,
            raAsc: chart.HousePositions.ascendant.rightAscension,
            lonAsc: chart.HousePositions.ascendant.longitude,
            oaAsc: oaAsc,
            oblEcl: chart.Obliquity,
            geoLat: geoLat
        )
    }

    // MARK: - FactorPointBase

    private func buildPointBase(
        pos: FullFactorPosition, specBase: SpecBase, config: PrimaryDirectionsConfig, isOpp: Bool
    ) -> FactorPointBase {
        let lon  = pos.ecliptical.first?.mainPos ?? 0
        let lat  = pos.ecliptical.first?.deviation ?? 0
        var ra   = pos.equatorial.first?.mainPos ?? 0
        var decl = pos.equatorial.first?.deviation ?? 0
        let azimuth  = pos.horizontal.first?.azimuth ?? 0
        let altitude = pos.horizontal.first?.altitude ?? 0

        if config.approach == .ecliptical {
            decl = CA.declFromLongNoLat(lon, obliquity: specBase.oblEcl)
            ra   = CA.rightAscFromLongNoLat(lon, obliquity: specBase.oblEcl)
        }

        let chartLeft: Bool
        let chartTop: Bool
        if config.approach == .mundane {
            chartLeft = CA.isChartLeft(ra,  mc: specBase.raMc)
            chartTop  = CA.isChartTop(ra,  asc: specBase.raAsc)
        } else {
            chartLeft = CA.isChartLeft(lon, mc: specBase.lonMc)
            chartTop  = CA.isChartTop(lon, asc: specBase.lonAsc)
        }

        if isOpp {
            return FactorPointBase(
                lon: CA.valueToRange(lon + 180, 0, 360), lat: -lat,
                ra:  CA.valueToRange(ra  + 180, 0, 360), decl: -decl,
                azimuth: CA.valueToRange(azimuth + 180, 0, 360), altitude: -altitude,
                chartLeft: !chartLeft, chartTop: !chartTop
            )
        }
        return FactorPointBase(lon: lon, lat: lat, ra: ra, decl: decl,
                               azimuth: azimuth, altitude: altitude,
                               chartLeft: chartLeft, chartTop: chartTop)
    }

    // MARK: - Placidus

    private func buildPlacSpec(
        pos: FullFactorPosition, specBase: SpecBase, config: PrimaryDirectionsConfig, isOpp: Bool
    ) -> FactorSpecPlac {
        let b     = buildPointBase(pos: pos, specBase: specBase, config: config, isOpp: isOpp)
        let north = specBase.geoLat >= 0
        let ad    = CA.ascensionalDifference(b.decl, geoLat: specBase.geoLat)
        let oad   = CA.obliqueAscDesc(b.ra, ascDiff: ad, chartLeft: b.chartLeft, north: north)
        let horDist = CA.horizontalDistance(oad, oaAsc: specBase.oaAsc, chartLeft: b.chartLeft, north: north)
        let merDist = CA.meridianDistance(b.ra, raMc: specBase.raMc, raIc: specBase.raIc, isTop: b.chartTop)
        let semiArc = b.chartTop ? (90 + ad) : (90 - ad)
        return FactorSpecPlac(base: b, ad: ad, oad: oad, horDist: horDist, merDist: merDist, semiArc: semiArc)
    }

    private func placidusArc(prom: FactorSpecPlac, sign: FactorSpecPlac, specBase: SpecBase) -> Double {
        let isSignTop  = sign.base.chartTop
        let isSignLeft = sign.base.chartLeft
        let quadrCorr: Double = ((isSignLeft && isSignTop) || (!isSignLeft && !isSignTop)) ? -1.0 : 1.0
        let r       = isSignTop ? specBase.raMc : specBase.raIc
        let horCorr: Double = isSignTop ? 1.0 : -1.0
        guard abs(sign.semiArc) > 0.000001 else { return .nan }
        let arc = prom.base.ra - r + quadrCorr * (90 + horCorr * prom.ad) * sign.merDist / sign.semiArc
        return CA.valueToRange(arc, 0, 360)
    }

    // MARK: - Regiomontanus

    private func buildRegSpec(
        pos: FullFactorPosition, specBase: SpecBase, config: PrimaryDirectionsConfig, isOpp: Bool
    ) -> FactorSpecReg {
        let b      = buildPointBase(pos: pos, specBase: specBase, config: config, isOpp: isOpp)
        let geoLat = specBase.geoLat
        let isTop: Bool = (config.approach == .mundane)
            ? CA.isChartTop(b.ra,  asc: specBase.raAsc)
            : CA.isChartTop(b.lon, asc: specBase.lonAsc)
        let merDist = CA.meridianDistance(b.ra, raMc: specBase.raMc, raIc: specBase.raIc, isTop: isTop)
        let zd      = CA.zenithDistReg(b.decl, merDist: merDist, geoLat: geoLat, isTop: isTop)
        let poleReg = CA.rad2deg(asin(sin(CA.deg2rad(geoLat)) * sin(CA.deg2rad(zd))))
        let tanProduct = tan(CA.deg2rad(b.decl)) * tan(CA.deg2rad(poleReg))
        guard abs(tanProduct) <= 1.0 else {
            return FactorSpecReg(base: b, merDist: merDist, zenithDist: zd, poleReg: poleReg,
                                 factorQ: 0, factorW: 0, invalid: true)
        }
        let factorQ = CA.rad2deg(asin(tanProduct))
        let factorW = b.chartLeft ? (b.ra - factorQ) : (b.ra + factorQ)
        return FactorSpecReg(base: b, merDist: merDist, zenithDist: zd, poleReg: poleReg,
                             factorQ: factorQ, factorW: factorW, invalid: false)
    }

    private func regiomontanusArc(prom: FactorSpecReg, sign: FactorSpecReg) -> Double {
        guard !sign.invalid else { return .nan }
        let x = tan(CA.deg2rad(prom.base.decl)) * tan(CA.deg2rad(sign.poleReg))
        guard abs(x) <= 1.0 else { return .nan }
        let qp = CA.rad2deg(asin(x))
        let wp = sign.base.chartLeft ? (prom.base.ra - qp) : (prom.base.ra + qp)
        return CA.valueToRange(wp - sign.factorW, 0, 360)
    }

    // MARK: - Time keys

    private func jdForEvent(natalJD: Double, arc: Double, key: PrimaryTimeKey, seWrapper: SEWrapper) -> Double {
        switch key {
        case .ptolemy:
            return natalJD + arc * TROPICAL_YEAR
        case .naibod:
            return natalJD + arc / NAIBOD * TROPICAL_YEAR
        case .brahe:
            let ra0   = calcSunEquatorial(jd: natalJD - 0.5, seWrapper: seWrapper)
            let ra1   = calcSunEquatorial(jd: natalJD + 0.5, seWrapper: seWrapper)
            let raDiff = CA.valueToRange(ra1 - ra0, 0, 360)
            guard raDiff > 0.001 else { return natalJD + arc / NAIBOD * TROPICAL_YEAR }
            return natalJD + arc / raDiff * TROPICAL_YEAR
        case .placidus:
            let sunRANatal = calcSunEquatorial(jd: natalJD, seWrapper: seWrapper)
            let targetRA   = CA.valueToRange(sunRANatal + arc, 0, 360)
            let estimatedJD = natalJD + arc * (360.0 / TROPICAL_YEAR)
            let secJD = findJDForSunPos(target: targetRA, estimated: estimatedJD, equatorial: true, seWrapper: seWrapper)
            return (secJD - natalJD) * TROPICAL_YEAR + natalJD
        case .vanDam:
            let sunLonNatal = calcSunEcliptical(jd: natalJD, seWrapper: seWrapper)
            let targetLon   = CA.valueToRange(sunLonNatal + arc, 0, 360)
            let estimatedJD = natalJD + arc * (360.0 / TROPICAL_YEAR)
            let secJD = findJDForSunPos(target: targetLon, estimated: estimatedJD, equatorial: false, seWrapper: seWrapper)
            return (secJD - natalJD) * TROPICAL_YEAR + natalJD
        }
    }

    private func calcSunEquatorial(jd: Double, seWrapper: SEWrapper) -> Double {
        let flags = 2 + 256 + 2048  // SEFLG_SWIEPH + SEFLG_SPEED + SEFLG_EQUATORIAL
        return seWrapper.calculateFactorPosition(julianDay: jd, factor: 0, flags: flags)?.mainPos ?? 0
    }

    private func calcSunEcliptical(jd: Double, seWrapper: SEWrapper) -> Double {
        let flags = 2 + 256  // SEFLG_SWIEPH + SEFLG_SPEED
        return seWrapper.calculateFactorPosition(julianDay: jd, factor: 0, flags: flags)?.mainPos ?? 0
    }

    private func findJDForSunPos(target: Double, estimated: Double, equatorial: Bool, seWrapper: SEWrapper) -> Double {
        let flags = equatorial ? (2 + 256 + 2048) : (2 + 256)
        var tempJD = estimated
        for _ in 0..<50 {
            guard let result = seWrapper.calculateFactorPosition(julianDay: tempJD, factor: 0, flags: flags) else { break }
            let delta = CA.valueToRange(result.mainPos - target, -180, 180)
            if abs(delta) < 0.0001 { break }
            tempJD -= delta
        }
        return tempJD
    }

    // MARK: - Date conversion

    private func jdToDateString(_ jd: Double, seWrapper: SEWrapper) -> String {
        let dt = seWrapper.dateFromJulianDay(jd)
        return String(format: "%04d/%02d/%02d", dt.Date.Year, dt.Date.Month, dt.Date.Day)
    }
}

// MARK: - Internal speculum types

private struct SpecBase {
    let raMc: Double
    let raIc: Double
    let lonMc: Double
    let raAsc: Double
    let lonAsc: Double
    let oaAsc: Double
    let oblEcl: Double
    let geoLat: Double
}

private struct FactorPointBase {
    let lon: Double
    let lat: Double
    let ra: Double
    let decl: Double
    let azimuth: Double
    let altitude: Double
    let chartLeft: Bool
    let chartTop: Bool
}

private struct FactorSpecPlac {
    let base: FactorPointBase
    let ad: Double
    let oad: Double
    let horDist: Double
    let merDist: Double
    let semiArc: Double
}

private struct FactorSpecReg {
    let base: FactorPointBase
    let merDist: Double
    let zenithDist: Double
    let poleReg: Double
    let factorQ: Double
    let factorW: Double
    let invalid: Bool
}
