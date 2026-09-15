// AdbXmlFieldParsers.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Field-level parsers for Astro-Databank XML attribute values that need
/// more than a plain `Int`/`Double` conversion. Kept independently testable,
/// per the format specification's call for dedicated coordinate/meridian tests.
enum AdbXmlFieldParsers {

    /// Parses a `slati`/`slong`-style coordinate, e.g. "52n04", "1w20".
    /// The official samples are not colon-delimited for seconds the way
    /// AAF's are; per the spec, seconds "can occur without a colon depending
    /// on the specific field format" — this parser treats any digits beyond
    /// the first two after the direction letter as trailing seconds (with a
    /// colon also accepted, for tolerance).
    static func parseCoordinate(_ raw: String, positiveChar: Character, negativeChar: Character) -> Double? {
        let lower = raw.lowercased()
        guard let dirIndex = lower.firstIndex(where: { $0 == positiveChar || $0 == negativeChar }) else { return nil }
        let degreesText = String(lower[lower.startIndex..<dirIndex])
        let isPositive = lower[dirIndex] == positiveChar
        var rest = String(lower[lower.index(after: dirIndex)...])

        var seconds = 0
        if let colonIndex = rest.firstIndex(of: ":") {
            seconds = Int(rest[rest.index(after: colonIndex)...]) ?? 0
            rest = String(rest[rest.startIndex..<colonIndex])
        } else if rest.count > 2 {
            seconds = Int(rest.suffix(rest.count - 2)) ?? 0
            rest = String(rest.prefix(2))
        }

        guard let degrees = Int(degreesText), let minutes = Int(rest) else { return nil }
        return GeoCoordinateConversion.decimalDegrees(degrees: degrees, minutes: minutes, seconds: seconds, isPositiveDirection: isPositive)
    }

    /// Parses `sbtime`'s `stmerid` attribute: "h1e"/"h5w" (a direct hour
    /// offset, optionally with trailing minutes) or "m72e30"/"m4w15" (a
    /// geographic meridian in degrees[+minutes], converted at 15° = 1 hour).
    static func parseMeridianOffsetSeconds(_ raw: String) -> Int? {
        guard let kind = raw.first else { return nil }
        let rest = raw.dropFirst()
        guard let dirIndex = rest.firstIndex(where: { $0 == "e" || $0 == "w" || $0 == "E" || $0 == "W" }) else { return nil }
        let numberText = String(rest[rest.startIndex..<dirIndex])
        let isPositive = rest[dirIndex] == "e" || rest[dirIndex] == "E"
        let trailingText = String(rest[rest.index(after: dirIndex)...])
        guard let number = Int(numberText) else { return nil }
        let trailing = trailingText.isEmpty ? 0 : (Int(trailingText) ?? 0)

        switch kind {
        case "h", "H":
            let seconds = number * 3600 + trailing * 60
            return isPositive ? seconds : -seconds
        case "m", "M":
            let degrees = Double(number) + Double(trailing) / 60.0
            let seconds = Int((degrees / 15.0 * 3600.0).rounded())
            return isPositive ? seconds : -seconds
        default:
            return nil
        }
    }

    /// Parses `sbtime`'s element text: "HH:mm" or "HH:mm:ss".
    static func parseTime(_ raw: String) -> (hour: Int, minute: Int, second: Int)? {
        let parts = raw.split(separator: ":").map(String.init)
        guard parts.count == 2 || parts.count == 3, let hour = Int(parts[0]), let minute = Int(parts[1]) else { return nil }
        let second = parts.count == 3 ? (Int(parts[2]) ?? 0) : 0
        guard hour >= 0 && hour <= 23, minute >= 0 && minute <= 59, second >= 0 && second <= 59 else { return nil }
        return (hour, minute, second)
    }
}
