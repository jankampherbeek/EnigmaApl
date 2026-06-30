// FixStarsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public struct FixStarsOrchestrator {

    // MARK: - Public API

    /// Calculate position and magnitude for a single fixed star.
    /// - Parameters:
    ///   - starName: traditional name of the star as listed in sefstars.txt
    ///   - jdUt: Julian day in Universal Time
    ///   - obsPos: observer position (geocentric, topocentric, heliocentric)
    ///   - ayanamsha: ayanamsha for sidereal calculations; use .tropical for tropical
    ///   - seWrapper: SEWrapper instance; caller must have called setTopocentric() beforehand if obsPos is .topoCentric
    /// - Returns: populated FixStarResult, or nil if the SE calculation fails
    public static func getFixStar(starName: String, jdUt: Double, obsPos: ObserverPositions, ayanamsha: Ayanamshas, seWrapper: SEWrapper) -> FixStarResult? {
        prepareWrapper(seWrapper: seWrapper, ayanamsha: ayanamsha)

        let eclFlags = buildFlags(obsPos: obsPos, ayanamsha: ayanamsha, equatorial: false)
        let eqFlags  = buildFlags(obsPos: obsPos, ayanamsha: ayanamsha, equatorial: true)

        guard let eclResult   = seWrapper.calculateFixStar(jdUt: jdUt, starName: starName, flags: eclFlags),
              let eqResult    = seWrapper.calculateFixStar(jdUt: jdUt, starName: starName, flags: eqFlags),
              let magnitude   = seWrapper.calculateFixStarMagnitude(starName: starName) else {
            Logger.log.error("FixStarsOrchestrator: failed to calculate star '\(starName)'")
            return nil
        }

        return FixStarResult(
            starName: starName.trimmingCharacters(in: .whitespaces),
            magnitude: magnitude,
            longitude: eclResult.mainPos,
            latitude: eclResult.deviation,
            declination: eqResult.deviation
        )
    }

    /// Calculate positions and magnitudes for a specific set of fixed stars.
    /// Stars for which the SE calculation fails are silently omitted from the result.
    public static func getFixStarSet(starNames: [String], jdUt: Double, obsPos: ObserverPositions, ayanamsha: Ayanamshas, seWrapper: SEWrapper) -> [FixStarResult] {
        return starNames.compactMap {
            getFixStar(starName: $0, jdUt: jdUt, obsPos: obsPos, ayanamsha: ayanamsha, seWrapper: seWrapper)
        }
    }

    /// Calculate positions and magnitudes for all fixed stars listed in sefstars.txt.
    /// Stars for which the SE calculation fails are silently omitted from the result.
    public static func getAllFixStars(jdUt: Double, obsPos: ObserverPositions, ayanamsha: Ayanamshas, seWrapper: SEWrapper) -> [FixStarResult] {
        let names = readStarNamesFromFile()
        return getFixStarSet(starNames: names, jdUt: jdUt, obsPos: obsPos, ayanamsha: ayanamsha, seWrapper: seWrapper)
    }

    public static func getSelection(selection: FixStarSelections) -> [StarDefinitions] {
        switch selection {
        case .ptolemy:
            return StarDefinitions.allCases.filter { $0.selectionMembership.inPtolemy }
        case .robson:
            return StarDefinitions.allCases.filter { $0.selectionMembership.inRobson }
        case .brady:
            return StarDefinitions.allCases.filter { $0.selectionMembership.inBrady }
        case .magnitude:
            return StarDefinitions.allCases
        case .selfDefined:
            return []
        }
    }

    // MARK: - Private helpers

    private static func prepareWrapper(seWrapper: SEWrapper, ayanamsha: Ayanamshas) {
        if ayanamsha != .tropical {
            seWrapper.setAyanamsha(idAyanamsha: ayanamsha.seId)
        }
    }

    /// Build SE iflag value for a fixed-star calculation.
    /// Mirrors the logic in SEFlags.defineFlags without requiring a full CalculationConfig.
    private static func buildFlags(obsPos: ObserverPositions, ayanamsha: Ayanamshas, equatorial: Bool) -> Int {
        var flags = 2 + 256     // SEFLG_SWIEPH + SEFLG_SPEED
        if equatorial {
            flags += 2048       // SEFLG_EQUATORIAL
        }
        if obsPos == .topoCentric {
            flags += 32 * 1024  // SEFLG_TOPOCTR
        }
        if obsPos == .helioCentric {
            flags += 8          // SEFLG_HELCTR
        }
        if ayanamsha != .tropical && !equatorial {
            flags += 64 * 1024  // SEFLG_SIDEREAL (ecliptical only)
        }
        return flags
    }

    /// Parse traditional star names from sefstars.txt, skipping comment lines and deduplicating.
    private static func readStarNamesFromFile() -> [String] {
        guard let path = findSefstarsPath() else {
            Logger.log.error("FixStarsOrchestrator: could not locate sefstars.txt")
            return []
        }
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            Logger.log.error("FixStarsOrchestrator: could not read sefstars.txt at \(path)")
            return []
        }

        var seen = Set<String>()
        return content.components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("#") && !$0.isEmpty }
            .compactMap { line -> String? in
                let name = line.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? ""
                guard !name.isEmpty else { return nil }
                return seen.insert(name).inserted ? name : nil
            }
    }

    /// Locate sefstars.txt using the same candidate paths as SEWrapper.initialize().
    private static func findSefstarsPath() -> String? {
        let filename = "sefstars.txt"
        let bundlesToCheck: [Bundle] = [Bundle.main, Bundle(for: SEWrapper.self)]

        for bundle in bundlesToCheck {
            if let resourcePath = bundle.resourcePath {
                let path = (resourcePath as NSString).appendingPathComponent("se/\(filename)")
                if FileManager.default.fileExists(atPath: path) { return path }
            }
            let path = bundle.bundlePath + "/Contents/Resources/se/\(filename)"
            if FileManager.default.fileExists(atPath: path) { return path }
        }

        let cwdPath = FileManager.default.currentDirectoryPath + "/EnigmaApl/CSwissEphemeris/se/\(filename)"
        if FileManager.default.fileExists(atPath: cwdPath) { return cwdPath }

        return nil
    }
}
