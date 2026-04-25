// WorkerHelpers.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Reads 8 bytes from `data` starting at `offset` and interprets them as a
/// little-endian Double.  Safe on all architectures: copies bytes one-by-one
/// into a local UInt64 so no alignment requirement is imposed on the source.
/// Returns `nil` if there are fewer than 8 bytes available.
@inline(__always)
func readDouble(from data: Data, at offset: Int) -> Double? {
    guard offset >= 0, offset + 8 <= data.count else { return nil }
    var raw: UInt64 = 0
    for i in 0..<8 {
        raw |= UInt64(data[data.startIndex + offset + i]) << (i * 8)
    }
    return Double(bitPattern: raw)
}
