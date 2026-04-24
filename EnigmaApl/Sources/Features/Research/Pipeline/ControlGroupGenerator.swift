// ControlGroupGenerator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Security

// MARK: - True-random shuffle

/// Fisher-Yates shuffle backed by `SecRandomCopyBytes` — cryptographically strong,
/// not pseudo-random. Equivalent to the C# `RandomNumberGenerator`-based shuffle.
private func secureShuffle<T>(_ array: inout [T]) {
    var n = array.count
    while n > 1 {
        n -= 1
        // Generate one unbiased random index in 0 ... n
        let k = secureRandomInt(upperBoundExclusive: n + 1)
        if k != n { array.swapAt(k, n) }
    }
}

/// Returns a cryptographically random Int in `0 ..< upperBoundExclusive`.
/// Uses rejection sampling to eliminate modulo bias.
private func secureRandomInt(upperBoundExclusive bound: Int) -> Int {
    guard bound > 1 else { return 0 }
    // Largest multiple of `bound` that fits in UInt32
    let maxUnbiased = UInt32.max - (UInt32.max % UInt32(bound))
    var raw: UInt32 = 0
    repeat {
        precondition(
            SecRandomCopyBytes(kSecRandomDefault, 4, &raw) == errSecSuccess,
            "SecRandomCopyBytes failed — system entropy unavailable"
        )
    } while raw > maxUnbiased
    return Int(raw % UInt32(bound))
}

// MARK: - Calendar helper

/// Returns true if `day` is a valid day-of-month for the given `month` and `year`.
private func dayFitsInMonth(_ day: Int, month: Int, year: Int) -> Bool {
    guard day >= 1 else { return false }
    switch month {
    case 2:
        let leap = (year % 400 == 0) || (year % 100 != 0 && year % 4 == 0)
        return day <= (leap ? 29 : 28)
    case 4, 6, 9, 11:
        return day <= 30
    default:
        return day <= 31
    }
}

// MARK: - Generator

/// Generates control-group records from real-data records using the same
/// "shuffle-all-columns-independently" strategy as the C# `StandardShiftControlGroupCreator`.
///
/// Each call to `generate(from:multiplicity:startId:)` returns `count × multiplicity`
/// synthetic records where all time/location fields are independently shuffled,
/// ensuring no record is a copy of any real input.
///
/// True randomness is provided by `SecRandomCopyBytes` — not `arc4random` or `Double.random`.
public struct ControlGroupGenerator {

    public init() {}

    /// Generates `inputRecords.count × multiplicity` control-group records.
    /// - Parameters:
    ///   - inputRecords: The real-data records to derive the control group from.
    ///   - multiplicity: How many independent shuffled sets to produce (matches `ResearchProjectModel.cgMultiplication`).
    ///   - startId: Id assigned to the first generated record; increments by 1 for each subsequent record.
    /// - Returns: All generated records, sets concatenated in order.
    public func generate(
        from inputRecords: [ResearchInputRecord],
        multiplicity: Int,
        startId: Int
    ) -> [ResearchInputRecord] {
        guard !inputRecords.isEmpty, multiplicity > 0 else { return [] }

        var allRecords: [ResearchInputRecord] = []
        allRecords.reserveCapacity(inputRecords.count * multiplicity)
        var nextId = startId

        for setIndex in 0..<multiplicity {
            let set = generateOneSet(from: inputRecords, setIndex: setIndex, startId: &nextId)
            allRecords.append(contentsOf: set)
        }
        return allRecords
    }

    // MARK: - Private

    private func generateOneSet(
        from inputRecords: [ResearchInputRecord],
        setIndex: Int,
        startId: inout Int
    ) -> [ResearchInputRecord] {
        // Extract each column into its own array
        var years    = inputRecords.map { $0.year }
        var months   = inputRecords.map { $0.month }
        var days     = inputRecords.map { $0.day }
        var hours    = inputRecords.map { $0.hour }
        var minutes  = inputRecords.map { $0.minute }
        var seconds  = inputRecords.map { $0.second }
        var offsets  = inputRecords.map { $0.offset }
        var geoLats  = inputRecords.map { $0.geoLat }
        var geoLons  = inputRecords.map { $0.geoLon }

        // Shuffle all columns independently using true randomness
        secureShuffle(&years)
        secureShuffle(&months)
        secureShuffle(&days)
        secureShuffle(&hours)
        secureShuffle(&minutes)
        secureShuffle(&seconds)
        secureShuffle(&offsets)
        secureShuffle(&geoLats)
        secureShuffle(&geoLons)

        // Re-pair: days are consumed in descending order (sorted desc first, as in C#)
        // to minimise invalid day/month combinations before the calendar fix-up below.
        days.sort(by: >)

        var result: [ResearchInputRecord] = []
        result.reserveCapacity(inputRecords.count)

        var remainingMonths = months  // mutable copy for the calendar fix-up

        for i in 0..<years.count {
            let year  = years[i]
            let day   = days[i]
            let month = findCompatibleMonth(day: day, year: year, remaining: &remainingMonths)
                     ?? remainingMonths.removeFirst()   // fallback: accept whatever is left

            result.append(ResearchInputRecord(
                id: startId,
                isData: false,
                geoLat: geoLats[i],
                geoLon: geoLons[i],
                year: year,
                month: month,
                day: day,
                hour: hours[i],
                minute: minutes[i],
                second: seconds[i],
                offset: offsets[i]
            ))
            startId += 1
        }
        return result
    }

    /// Finds and removes the first month from `remaining` that is compatible with the given day/year.
    /// Returns `nil` if no compatible month is found (caller must handle fallback).
    private func findCompatibleMonth(day: Int, year: Int, remaining: inout [Int]) -> Int? {
        for i in 0..<remaining.count {
            if dayFitsInMonth(day, month: remaining[i], year: year) {
                return remaining.remove(at: i)
            }
        }
        return nil
    }
}
