// BlaSchemaPresentables.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Category enums (localized at display time by the views, never carry raw English text)

/// The 3 crosses and 4 elements, shared by the Crosses/Elements counts and the Cycles tables.
enum CrossElementGroup: CaseIterable, Hashable {
    case cardinal, fixed, mutable, fire, earth, air, water

    /// Signs (1-12) belonging to this group. Only meaningful for the 3 crosses / 4 elements, not used for cycles.
    var signs: [Int] {
        switch self {
        case .cardinal: return [1, 4, 7, 10]
        case .fixed: return [2, 5, 8, 11]
        case .mutable: return [3, 6, 9, 12]
        case .fire: return [1, 5, 9]
        case .earth: return [2, 6, 10]
        case .air: return [3, 7, 11]
        case .water: return [4, 8, 12]
        }
    }

    fileprivate static func crossFor(sign: Int) -> CrossElementGroup? {
        switch sign {
        case 1, 4, 7, 10: return .cardinal
        case 2, 5, 8, 11: return .fixed
        case 3, 6, 9, 12: return .mutable
        default: return nil
        }
    }

    fileprivate static func elementFor(sign: Int) -> CrossElementGroup? {
        switch sign {
        case 1, 5, 9: return .fire
        case 2, 6, 10: return .earth
        case 3, 7, 11: return .air
        case 4, 8, 12: return .water
        default: return nil
        }
    }
}

/// The 6 fixed rows shown in the BLA "Details" block.
enum BlaDetailKind: CaseIterable, Hashable {
    case sisterSignAsc, clampedHouses, interceptedSigns, groundNote, lordAscInHouses, moonInHouse
}

// MARK: - Presentable structs (bound directly to SwiftUI tables)

struct PresentableBlaPosition: Identifiable {
    let id = UUID()
    let factor: String
    let position: String
    let sign: String
    let house: String
    let decanate: String
}

struct PresentableHousePosition: Identifiable {
    var id: Int { number }
    let number: Int
    let position: String
    let sign: String
    let decanate: String
}

struct PresentableCrossElementsCount: Identifiable {
    var id: String { "\(group)" }
    let group: CrossElementGroup
    let sign: Int
    let house: Int
    let sum: Int
    let hCusp: Int
    let total: Int
}

struct PresentableQuadrantCount: Identifiable {
    var id: Int { quadrant }
    let quadrant: Int
    let count: Int
}

struct PresentableDecanateCount: Identifiable {
    let id = UUID()
    let rulerGlyph: String
    let count: Int
}

struct PresentableDispositorCounts: Identifiable {
    let id = UUID()
    let rulers: String
    let signSplitted: String
    let signMain: Int
    let signIndirect: Int
    let signSum: Int
    let houseMain: Int
    let houseIndirect: Int
    let houseSum: Int
    let decanateDirect: Int
    let total: Int
}

struct PresentableBlaDetails: Identifiable {
    var id: Int { kind.hashValue }
    let kind: BlaDetailKind
    let text: String
    let glyphs: String
}

struct PresentableBlaCycle: Identifiable {
    var id: String { "\(group)" }
    let group: CrossElementGroup
    let description: String
}

struct PresentableReinforcementFactor: Identifiable {
    let id = UUID()
    let factor: String
    let position: Int
    let positionGlyph: String
}

struct PresentablePairAnalogHouseSign: Identifiable {
    let id = UUID()
    let factor1: String
    let factor2: String
    let house: String
    let sign: String
}

struct PresentableReception: Identifiable {
    let id = UUID()
    let factor1: String
    let factor2: String
    let position1: String
    let position2: String
}

// MARK: - Shared glyph helpers

private enum BlaGlyphs {
    static func signGlyph(_ signIndex: Int) -> String {
        guard let sign = Signs(rawValue: signIndex) else { return "?" }
        return GlyphSelector.getGlyphForSign(sign)
    }

    static func decanateGlyph(_ decanate: Int) -> String {
        guard let ruler = BlaSchemaDomain.decanateRulers().first(where: { $0.decan == decanate })?.ruler else { return " " }
        return GlyphSelector.getGlyphForFactor(ruler)
    }

    static func factorGlyph(_ factor: Factors) -> String {
        GlyphSelector.getGlyphForFactor(factor)
    }
}

// MARK: - Factories

enum BlaSchemaPresentables {

    // MARK: Positions

    static func blaPositions(from pointDetails: [BlaPointDetails]) -> [PresentableBlaPosition] {
        pointDetails.map { pd in
            let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(normalized(pd.longitude))
            let signGlyph = sign.map { GlyphSelector.getGlyphForSign($0) } ?? "?"
            return PresentableBlaPosition(
                factor: BlaGlyphs.factorGlyph(pd.point), position: dms, sign: signGlyph,
                house: "\(pd.house)", decanate: BlaGlyphs.decanateGlyph(pd.decanate)
            )
        }
    }

    static func housePositions(from houseDetails: [BlaHouseDetails]) -> [PresentableHousePosition] {
        houseDetails.map { hd in
            let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(normalized(hd.longitude))
            let signGlyph = sign.map { GlyphSelector.getGlyphForSign($0) } ?? "?"
            return PresentableHousePosition(number: hd.houseNr, position: dms, sign: signGlyph, decanate: BlaGlyphs.decanateGlyph(hd.decanate))
        }
    }

    private static func normalized(_ longitude: Double) -> Double {
        var lon = longitude.truncatingRemainder(dividingBy: 360.0)
        if lon < 0 { lon += 360.0 }
        return lon
    }

    // MARK: Crosses / Elements counts

    static func crossesCounts(signCounts: [Int: Int], houseCounts: [Int: Int], planetsInHouses: [Factors: Int], signOnCusps: [Int: Int]) -> [PresentableCrossElementsCount] {
        var sCounts: [CrossElementGroup: Int] = [:]
        var hCounts: [CrossElementGroup: Int] = [:]
        var cCounts: [CrossElementGroup: Int] = [:]

        for (sign, count) in signCounts {
            guard let group = CrossElementGroup.crossFor(sign: sign) else { continue }
            sCounts[group, default: 0] += count
        }
        for (point, house) in planetsInHouses {
            guard !angleFactorsForCounts.contains(point) else { continue }
            guard let group = CrossElementGroup.crossFor(sign: house) else { continue }
            hCounts[group, default: 0] += 1
        }
        for (house, sign) in signOnCusps {
            guard let group = CrossElementGroup.crossFor(sign: sign) else { continue }
            cCounts[group, default: 0] += houseCounts[house] ?? 0
        }

        return [.cardinal, .fixed, .mutable].map { line(for: $0, sCounts: sCounts, hCounts: hCounts, cCounts: cCounts) }
    }

    static func elementsCounts(signCounts: [Int: Int], planetsInHouses: [Factors: Int], signOnCusps: [Int: Int]) -> [PresentableCrossElementsCount] {
        var sCounts: [CrossElementGroup: Int] = [:]
        var hCounts: [CrossElementGroup: Int] = [:]
        var cCounts: [CrossElementGroup: Int] = [:]

        for (sign, count) in signCounts {
            guard let group = CrossElementGroup.elementFor(sign: sign) else { continue }
            sCounts[group, default: 0] += count
        }

        var pointsPerHouse: [Int: Int] = Dictionary(uniqueKeysWithValues: (1...12).map { ($0, 0) })
        for (point, house) in planetsInHouses where !angleFactorsForCounts.contains(point) {
            pointsPerHouse[house, default: 0] += 1
        }
        for (house, count) in pointsPerHouse {
            guard let group = CrossElementGroup.elementFor(sign: house) else { continue }
            hCounts[group, default: 0] += count
        }
        for (house, sign) in signOnCusps {
            guard let group = CrossElementGroup.elementFor(sign: sign) else { continue }
            cCounts[group, default: 0] += pointsPerHouse[house] ?? 0
        }

        return [.fire, .earth, .air, .water].map { line(for: $0, sCounts: sCounts, hCounts: hCounts, cCounts: cCounts) }
    }

    private static let angleFactorsForCounts: Set<Factors> = [.ascendant, .mc, .eastPoint, .vertex]

    private static func line(for group: CrossElementGroup, sCounts: [CrossElementGroup: Int], hCounts: [CrossElementGroup: Int], cCounts: [CrossElementGroup: Int]) -> PresentableCrossElementsCount {
        let sign = sCounts[group] ?? 0
        let house = hCounts[group] ?? 0
        let sum = sign + house
        let hCusp = cCounts[group] ?? 0
        return PresentableCrossElementsCount(group: group, sign: sign, house: house, sum: sum, hCusp: hCusp, total: sum + hCusp)
    }

    // MARK: Quadrants

    static func quadrantCounts(from counts: [Int: Int]) -> [PresentableQuadrantCount] {
        (1...4).map { PresentableQuadrantCount(quadrant: $0, count: counts[$0] ?? 0) }
    }

    // MARK: Decanates

    static func decanateCounts(from counts: [Factors: Int]) -> [PresentableDecanateCount] {
        BlaSchemaDomain.decanateRulers().map { decanateRuler in
            PresentableDecanateCount(rulerGlyph: BlaGlyphs.factorGlyph(decanateRuler.ruler), count: counts[decanateRuler.ruler] ?? 0)
        }
    }

    // MARK: Dispositors

    static func dispositorCounts(from lines: [BlaDispositorLine]) -> [PresentableDispositorCounts] {
        lines.map { line in
            let rulers = "\(BlaGlyphs.factorGlyph(line.mainRuler)) \(BlaGlyphs.factorGlyph(line.subRuler))"
            let signSplitted = "\(line.mainRulerSignCount)/\(line.subRulerSignCount)"
            return PresentableDispositorCounts(
                rulers: rulers, signSplitted: signSplitted,
                signMain: line.sumRulerSignCount, signIndirect: line.indirectRulerSignCount, signSum: line.totalRulerSignCount,
                houseMain: line.directRulerHouseCount, houseIndirect: line.indirectRulerHouseCount, houseSum: line.sumRulerHouseCount,
                decanateDirect: line.directRulerDecanateCount, total: line.total
            )
        }
    }

    // MARK: Details

    static func blaDetails(from data: BlaDetailsData) -> [PresentableBlaDetails] {
        [
            PresentableBlaDetails(kind: .sisterSignAsc, text: "\(data.sisterSignAsc)", glyphs: BlaGlyphs.signGlyph(data.sisterSignAsc)),
            PresentableBlaDetails(kind: .clampedHouses, text: data.clampedHouses.map { "\($0)" }.joined(separator: " - "), glyphs: ""),
            PresentableBlaDetails(kind: .interceptedSigns, text: data.interceptedSigns.map { "\($0)" }.joined(separator: " - "), glyphs: data.interceptedSigns.map { BlaGlyphs.signGlyph($0) }.joined(separator: " ")),
            PresentableBlaDetails(kind: .groundNote, text: data.groundNote.map { "\($0)" }.joined(separator: " - "), glyphs: ""),
            PresentableBlaDetails(kind: .lordAscInHouses, text: data.lordAscInHouses.map { "\($0)" }.joined(separator: " - "), glyphs: ""),
            PresentableBlaDetails(kind: .moonInHouse, text: "\(data.moonInHouse)", glyphs: "")
        ]
    }

    // MARK: Cycles

    static func blaCycles(from data: BlaCyclesData) -> [PresentableBlaCycle] {
        CrossElementGroup.allCases.map { group in
            PresentableBlaCycle(group: group, description: cycleDescription(pairs(for: group, in: data)))
        }
    }

    static func shortenedCycles(from data: BlaCyclesData) -> [PresentableBlaCycle] {
        CrossElementGroup.allCases.map { group in
            PresentableBlaCycle(group: group, description: shortenedCycleDescription(pairs(for: group, in: data)))
        }
    }

    private static func pairs(for group: CrossElementGroup, in data: BlaCyclesData) -> [(Int, Int)] {
        switch group {
        case .cardinal: return data.cardinal
        case .fixed: return data.fixed
        case .mutable: return data.mutable
        case .fire: return data.fire
        case .earth: return data.earth
        case .air: return data.air
        case .water: return data.water
        }
    }

    /// Cycle pairs that occur more than once in the list get an asterisk on their first occurrence
    /// and are omitted on subsequent occurrences.
    private static func cycleDescription(_ cycles: [(Int, Int)]) -> String {
        var doubleValues: [(Int, Int)] = []
        for i in 0..<cycles.count {
            for j in (i + 1)..<cycles.count where cycles[i] == cycles[j] {
                doubleValues.append(cycles[i])
            }
        }

        var handled: [(Int, Int)] = []
        var parts: [String] = []
        for cycle in cycles {
            var asterisk = ""
            if doubleValues.contains(where: { $0 == cycle }) {
                if handled.contains(where: { $0 == cycle }) { continue }
                asterisk = "*"
                handled.append(cycle)
            }
            parts.append("\(cycle.0)>>\(cycle.1)\(asterisk)")
        }
        return parts.joined(separator: ", ")
    }

    private static func shortenedCycleDescription(_ cycles: [(Int, Int)]) -> String {
        cycles.map { "L.\($0.0) = L.\($0.1)" }.joined(separator: ", ")
    }

    // MARK: Reinforcements

    static func reinforcementFactors(from factors: [Factors: Int], blackMoonCorrectionType: BlackMoonCorrectionType) -> [PresentableReinforcementFactor] {
        let sequence = BlaSchemaDomain.standardSequence(blackMoonCorrectionType: blackMoonCorrectionType)
        let knownPoints = sequence.filter { factors[$0] != nil }
        let extraPoints = factors.keys
            .filter { !sequence.contains($0) }
            .sorted { $0.rawValue < $1.rawValue }
        return (knownPoints + extraPoints).map { point in
            let position = factors[point]!
            return PresentableReinforcementFactor(factor: BlaGlyphs.factorGlyph(point), position: position, positionGlyph: BlaGlyphs.signGlyph(position))
        }
    }

    static func pairsAnalogHouseSign(from pairs: [FactorPairAnalogHouseSign]) -> [PresentablePairAnalogHouseSign] {
        pairs.map { fp in
            PresentablePairAnalogHouseSign(
                factor1: BlaGlyphs.factorGlyph(fp.pointInSign), factor2: BlaGlyphs.factorGlyph(fp.pointInHouse),
                house: "\(fp.house)", sign: BlaGlyphs.signGlyph(fp.sign)
            )
        }
    }

    // MARK: Receptions

    static func receptionsInSigns(from receptions: [Reception]) -> [PresentableReception] {
        receptions.map { rec in
            PresentableReception(
                factor1: BlaGlyphs.factorGlyph(rec.point1), factor2: BlaGlyphs.factorGlyph(rec.point2),
                position1: BlaGlyphs.signGlyph(rec.signOrHouse1), position2: BlaGlyphs.signGlyph(rec.signOrHouse2)
            )
        }
    }

    static func receptionsInHouses(from receptions: [Reception]) -> [PresentableReception] {
        receptions.map { rec in
            PresentableReception(
                factor1: BlaGlyphs.factorGlyph(rec.point1), factor2: BlaGlyphs.factorGlyph(rec.point2),
                position1: "\(rec.signOrHouse1)", position2: "\(rec.signOrHouse2)"
            )
        }
    }
}
