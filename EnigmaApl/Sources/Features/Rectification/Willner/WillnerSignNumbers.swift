// WillnerSignNumbers.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Computes the candidate degree-offset numbers for Moon and Uranus used in the
/// Willner Moment-of-Incarnation algorithm.
///
/// Port of Number.cs / G_Number_S() from the Willner reference implementation.
///
/// The algorithm derives up to 4 integer "numbers" per body (indexed 1–4; 0 = unused)
/// from a sign-based arithmetic involving the body's sign and the Sun's sign.
/// These numbers are later added to the RAMC value to produce candidate LST positions.
struct WillnerSignNumbers {

    /// Computes MOONUM[1..4] and URANUM[1..4].  Index 0 is always 0 (unused).
    ///
    /// - Parameters:
    ///   - sunSign: Sun zodiac sign (1–12).
    ///   - moonSign: Moon zodiac sign (1–12).
    ///   - uranusSign: Uranus zodiac sign (1–12).
    /// - Returns: (moonNums, uranusNums) — each is an array of 5 Int (index 0 unused, values 0–∞ or 0 = skip).
    static func calculate(sunSign: Int, moonSign: Int, uranusSign: Int) -> (moonNums: [Int], uranusNums: [Int]) {
        var moonNums   = [Int](repeating: 0, count: 5)
        var uranusNums = [Int](repeating: 0, count: 5)

        moonNums   = computeNums(bodySign: moonSign,   sunSign: sunSign, offset: 17)
        uranusNums = computeNums(bodySign: uranusSign, sunSign: sunSign, offset: 22)

        // Remove duplicates within each array
        moonNums   = deduplicate(moonNums)
        uranusNums = deduplicate(uranusNums)

        return (moonNums, uranusNums)
    }

    // MARK: - Private

    /// Mirrors the sign-arithmetic from Number.cs for one body.
    /// `offset` is 17 for Moon and 22 for Uranus (from the C# code).
    private static func computeNums(bodySign: Int, sunSign: Int, offset: Int) -> [Int] {
        var nums = [Int](repeating: 0, count: 5)

        var num  = offset - bodySign          // e.g. 17 - moonSign
        if num > 12 { num -= 12 }

        var num2 = offset - sunSign           // e.g. 17 - sunSign
        if num2 > 12 { num2 -= 12 }

        var num3 = num * num2 + 30
        var num4 = Int((Double(num3 - num2) / 12.0).rounded(.down))

        nums[2] = 0
        nums[1] = num2 + num4 * 12
        if (num3 - nums[1]) >= 6 { nums[2] = nums[1] + 12 }
        if (num3 - nums[1]) > 6  { nums[1] = 0 }

        nums[3] = 0
        nums[4] = 0

        // Special case: if either num or num2 was 1, treat it as 12
        var numA = num
        var num2A = num2
        if numA  == 1 { numA  = 12 }
        if num2A == 1 { num2A = 12 }

        if numA == 12 || num2A == 12 {
            num3 = numA * num2A + 30
            num4 = Int((Double(num3 - num2A) / 12.0).rounded(.down))
            nums[3] = num2A + num4 * 12
            if (num3 - nums[3]) >= 6 { nums[4] = nums[3] + 12 }
            if (num3 - nums[3]) > 6  { nums[3] = 0 }
        }

        return nums
    }

    /// Removes duplicates: if a later index equals an earlier one, zero it out.
    /// Mirrors the deduplication loops in Number.cs exactly.
    private static func deduplicate(_ nums: [Int]) -> [Int] {
        var n = nums

        // indices 2..4 vs index 1
        for i in 2...4 {
            if n[i] == n[1] { n[i] = 0 }
        }
        // indices 3..4 vs index 2
        for i in 3...4 {
            if n[i] == n[2] { n[i] = 0 }
        }
        // index 3 vs index 4
        if n[3] == n[4] { n[3] = 0 }

        return n
    }
}
