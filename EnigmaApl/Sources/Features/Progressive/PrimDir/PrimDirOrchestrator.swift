// PrimDirOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

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

        let promissors = config.promissors.filter { chart.Coordinates[$0] != nil }
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
        let lon = pos.ecliptical.first?.mainPos ?? 0
        let lat = pos.ecliptical.first?.deviation ?? 0
        var ra = pos.equatorial.first?.mainPos ?? 0
        var decl = pos.equatorial.first?.deviation ?? 0
        let azimuth = pos.horizontal.first?.azimuth ?? 0
        let altitude = pos.horizontal.first?.altitude ?? 0

        if config.approach == .ecliptical {
            decl = declFromLon(lon, obl: specBase.oblEcl)
            ra = raFromLon(lon, obl: specBase.oblEcl)
        }

        let chartLeft: Bool
        let chartTop: Bool
        if config.approach == .mundane {
            chartLeft = isChartLeft(pos: ra, mc: specBase.raMc)
            chartTop = isChartTop(pos: ra, asc: specBase.raAsc)
        } else {
            chartLeft = isChartLeft(pos: lon, mc: specBase.lonMc)
            chartTop = isChartTop(pos: lon, asc: specBase.lonAsc)
        }

        if isOpp {
            return FactorPointBase(
                lon: valueToRange(lon + 180, 0, 360), lat: -lat,
                ra: valueToRange(ra + 180, 0, 360), decl: -decl,
                azimuth: valueToRange(azimuth + 180, 0, 360), altitude: -altitude,
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
        let b = buildPointBase(pos: pos, specBase: specBase, config: config, isOpp: isOpp)
        let north = specBase.geoLat >= 0
        let ad = ascDiff(decl: b.decl, geoLat: specBase.geoLat)
        let oad = obliqueAscDesc(ra: b.ra, ad: ad, chartLeft: b.chartLeft, north: north)
        let horDist = horizontalDist(oa: oad, oaAsc: specBase.oaAsc, chartLeft: b.chartLeft, north: north)
        let merDist = meridianDist(ra: b.ra, raMc: specBase.raMc, raIc: specBase.raIc, isTop: b.chartTop)
        let semiArc = b.chartTop ? (90 + ad) : (90 - ad)
        return FactorSpecPlac(base: b, ad: ad, oad: oad, horDist: horDist, merDist: merDist, semiArc: semiArc)
    }

    private func placidusArc(prom: FactorSpecPlac, sign: FactorSpecPlac, specBase: SpecBase) -> Double {
        let isSignTop = sign.base.chartTop
        let isSignLeft = sign.base.chartLeft
        let quadrCorr: Double = ((isSignLeft && isSignTop) || (!isSignLeft && !isSignTop)) ? -1.0 : 1.0
        let r = isSignTop ? specBase.raMc : specBase.raIc
        let horCorr: Double = isSignTop ? 1.0 : -1.0
        guard abs(sign.semiArc) > 0.000001 else { return .nan }
        let arc = prom.base.ra - r + quadrCorr * (90 + horCorr * prom.ad) * sign.merDist / sign.semiArc
        return valueToRange(arc, 0, 360)
    }

    // MARK: - Regiomontanus

    private func buildRegSpec(
        pos: FullFactorPosition, specBase: SpecBase, config: PrimaryDirectionsConfig, isOpp: Bool
    ) -> FactorSpecReg {
        let b = buildPointBase(pos: pos, specBase: specBase, config: config, isOpp: isOpp)
        let geoLat = specBase.geoLat
        let isTop: Bool = (config.approach == .mundane)
            ? isChartTop(pos: b.ra, asc: specBase.raAsc)
            : isChartTop(pos: b.lon, asc: specBase.lonAsc)
        let merDist = meridianDist(ra: b.ra, raMc: specBase.raMc, raIc: specBase.raIc, isTop: isTop)
        let zd = zenithDistReg(decl: b.decl, merDist: merDist, geoLat: geoLat, isTop: isTop)
        let geoLatRad = deg2rad(geoLat)
        let zdRad = deg2rad(zd)
        let poleReg = rad2deg(asin(sin(geoLatRad) * sin(zdRad)))
        let poleRad = deg2rad(poleReg)
        let declRad = deg2rad(b.decl)
        let tanProduct = tan(declRad) * tan(poleRad)
        guard abs(tanProduct) <= 1.0 else { return FactorSpecReg(base: b, merDist: merDist, zenithDist: zd, poleReg: poleReg, factorQ: 0, factorW: 0, invalid: true) }
        let factorQ = rad2deg(asin(tanProduct))
        let factorW = b.chartLeft ? (b.ra - factorQ) : (b.ra + factorQ)
        return FactorSpecReg(base: b, merDist: merDist, zenithDist: zd, poleReg: poleReg, factorQ: factorQ, factorW: factorW, invalid: false)
    }

    private func regiomontanusArc(prom: FactorSpecReg, sign: FactorSpecReg) -> Double {
        guard !sign.invalid else { return .nan }
        let x = tan(deg2rad(prom.base.decl)) * tan(deg2rad(sign.poleReg))
        guard abs(x) <= 1.0 else { return .nan }
        let qp = rad2deg(asin(x))
        let wp = sign.base.chartLeft ? (prom.base.ra - qp) : (prom.base.ra + qp)
        return valueToRange(wp - sign.factorW, 0, 360)
    }

    // MARK: - Time keys

    private func jdForEvent(natalJD: Double, arc: Double, key: PrimaryTimeKey, seWrapper: SEWrapper) -> Double {
        switch key {
        case .ptolemy:
            return natalJD + arc * TROPICAL_YEAR
        case .naibod:
            return natalJD + arc / NAIBOD * TROPICAL_YEAR
        case .brahe:
            let ra0 = calcSunEquatorial(jd: natalJD - 0.5, seWrapper: seWrapper)
            let ra1 = calcSunEquatorial(jd: natalJD + 0.5, seWrapper: seWrapper)
            let raDiff = valueToRange(ra1 - ra0, 0, 360)
            guard raDiff > 0.001 else { return natalJD + arc / NAIBOD * TROPICAL_YEAR }
            return natalJD + arc / raDiff * TROPICAL_YEAR
        case .placidus:
            let sunRANatal = calcSunEquatorial(jd: natalJD, seWrapper: seWrapper)
            let targetRA = valueToRange(sunRANatal + arc, 0, 360)
            let estimatedJD = natalJD + arc * (360.0 / TROPICAL_YEAR)
            let secJD = findJDForSunPos(target: targetRA, estimated: estimatedJD, equatorial: true, seWrapper: seWrapper)
            return (secJD - natalJD) * TROPICAL_YEAR + natalJD
        case .vanDam:
            let sunLonNatal = calcSunEcliptical(jd: natalJD, seWrapper: seWrapper)
            let targetLon = valueToRange(sunLonNatal + arc, 0, 360)
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
            let delta = valueToRange(result.mainPos - target, -180, 180)
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

    // MARK: - Math helpers

    private func deg2rad(_ deg: Double) -> Double { deg * .pi / 180.0 }
    private func rad2deg(_ rad: Double) -> Double { rad * 180.0 / .pi }

    private func valueToRange(_ value: Double, _ min: Double, _ max: Double) -> Double {
        let range = max - min
        var result = value
        while result < min { result += range }
        while result >= max { result -= range }
        return result
    }

    private func isChartLeft(pos: Double, mc: Double) -> Bool {
        valueToRange(pos - mc, 0, 360) < 180
    }

    private func isChartTop(pos: Double, asc: Double) -> Bool {
        valueToRange(pos - asc, 0, 360) > 180
    }

    private func ascDiff(decl: Double, geoLat: Double) -> Double {
        let x = tan(deg2rad(decl)) * tan(deg2rad(geoLat))
        guard abs(x) <= 1.0 else { return 0.0 }
        return rad2deg(asin(x))
    }

    private func obliqueAscDesc(ra: Double, ad: Double, chartLeft: Bool, north: Bool) -> Double {
        let oa: Double
        if north {
            oa = chartLeft ? ra - ad : ra + ad
        } else {
            oa = chartLeft ? ra + ad : ra - ad
        }
        return valueToRange(oa, 0, 360)
    }

    private func meridianDist(ra: Double, raMc: Double, raIc: Double, isTop: Bool) -> Double {
        let raMcIc = isTop ? raMc : raIc
        var shortArc = valueToRange(abs(ra - raMcIc), 0, 360)
        if shortArc >= 180 { shortArc = abs(360 - shortArc) }
        return shortArc
    }

    private func horizontalDist(oa: Double, oaAsc: Double, chartLeft: Bool, north: Bool) -> Double {
        var hd: Double
        if north {
            if chartLeft { hd = abs(oa - oaAsc) }
            else { hd = abs(valueToRange(oa + 180, 0, 180) - valueToRange(oaAsc + 180, 0, 180)) }
        } else {
            if !chartLeft { hd = abs(oa - oaAsc) }
            else { hd = abs(valueToRange(oa + 180, 0, 180) - valueToRange(oaAsc + 180, 0, 180)) }
        }
        if hd >= 180 { hd = 360 - hd }
        if hd >= 90 { hd = 180 - hd }
        return hd
    }

    private func declFromLon(_ lon: Double, obl: Double) -> Double {
        rad2deg(asin(sin(deg2rad(obl)) * sin(deg2rad(lon))))
    }

    private func raFromLon(_ lon: Double, obl: Double) -> Double {
        valueToRange(rad2deg(atan2(sin(deg2rad(lon)) * cos(deg2rad(obl)), cos(deg2rad(lon)))), 0, 360)
    }

    private func zenithDistReg(decl: Double, merDist: Double, geoLat: Double, isTop: Bool) -> Double {
        let declRad = deg2rad(decl)
        let mdRad = deg2rad(merDist)
        let glRad = deg2rad(geoLat)

        if abs(merDist - 90) < 0.000001 {
            return 90 - rad2deg(atan(sin(abs(glRad)) * tan(declRad)))
        }

        let a = rad2deg(atan(cos(glRad) * tan(mdRad)))
        let b = rad2deg(atan(tan(abs(glRad)) * cos(mdRad)))
        let c: Double
        if (decl >= 0 && geoLat >= 0) || (decl < 0 && geoLat < 0) {
            c = isTop ? b - abs(decl) : b + abs(decl)
        } else {
            c = isTop ? b + abs(decl) : b - abs(decl)
        }
        var f: Double = 0
        if abs(b - decl) >= 0.0000001 {
            f = rad2deg(atan(sin(abs(glRad)) * sin(mdRad) * tan(deg2rad(c))))
        }
        var zd = a + f
        if zd < 0 { zd += 180 }
        return zd
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
