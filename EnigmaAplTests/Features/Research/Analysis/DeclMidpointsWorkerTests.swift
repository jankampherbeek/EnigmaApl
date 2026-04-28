// DeclMidpointsWorkerTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

// MARK: - Helpers

private func writeDoubleLE(_ value: Double, into buffer: inout [UInt8], at offset: Int) {
    var le = value.bitPattern.littleEndian
    withUnsafeMutableBytes(of: &le) { buffer.replaceSubrange(offset..<offset + 8, with: $0) }
}

/// Writes a full binary record (prefix + Moon data + Uranus data) directly to the file.
private func writeRawRecord(
    to fileURL: URL,
    at position: Int,        // 0-based record index
    recordSize: Int,
    recordId: Int,
    isData: Bool,
    moonDecl: Double,
    uranusDecl: Double
) throws {
    var bytes = [UInt8](repeating: 0, count: recordSize)

    // Prefix: recordId (Int64 LE at 0) + isData (UInt8 at 8) + 7 pad bytes
    var rid = Int64(recordId).littleEndian
    withUnsafeMutableBytes(of: &rid) { bytes.replaceSubrange(0..<8, with: $0) }
    bytes[8] = isData ? 1 : 0

    // Data region starts at byte 16.
    // Moon layout: byteOffset=0 → RA at data[0], decl at data[8]
    // Uranus layout: byteOffset=40 → RA at data[40], decl at data[48]
    let dataBase = 16
    writeDoubleLE(0.0,       into: &bytes, at: dataBase + 0)   // Moon RA
    writeDoubleLE(moonDecl,  into: &bytes, at: dataBase + 8)   // Moon declination
    // bytes 16-39: distance, speeds → remain 0
    writeDoubleLE(0.0,       into: &bytes, at: dataBase + 40)  // Uranus RA
    writeDoubleLE(uranusDecl, into: &bytes, at: dataBase + 48) // Uranus declination
    // bytes 56-79: distance, speeds → remain 0

    let kHeaderSize = 256
    let fileOffset = kHeaderSize + position * recordSize

    guard let handle = try? FileHandle(forWritingTo: fileURL) else {
        struct OpenError: Error {}
        throw OpenError()
    }
    defer { try? handle.close() }
    try handle.seek(toOffset: UInt64(fileOffset))
    handle.write(Data(bytes))
}

// MARK: - Tests

struct DeclMidpointsWorkerTests {

    /// Moon: -19°07'50" = -19.1306°   Uranus: -18°21'32" = -18.3589°
    /// Midpoint: -18°44'41" = -18.7447°
    /// Distance of each pair member from midpoint ≈ 23'09" ≈ 0.386° — within orb of 0.5°.
    @Test("DeclMidpointsWorker finds Moon and Uranus as occupants of their own midpoint")
    func testMoonUranusOccupyOwnMidpoint() throws {
        // ── Config ───────────────────────────────────────────────────────────────
        let calcConfig = CalculationConfig()
        let calcConfigJson = String(data: try JSONEncoder().encode(calcConfig), encoding: .utf8)!

        // Moon rawValue=1, Uranus rawValue=8
        let config = ResearchConfig(
            enabledFactorIds: [Factors.moon.rawValue, Factors.uranus.rawValue],
            inquiryId: Inquiries.declMidpoints.rawValue,
            houseSystemId: HouseSystems.placidus.rawValue,
            calculationConfigJson: calcConfigJson
        )

        // ── Binary file ───────────────────────────────────────────────────────────
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeclMidpointsWorkerTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let file = try ResultsBinaryFile.create(
            at: tmpDir.path, config: config, recordCount: 1
        )

        let resultsBinURL = tmpDir.appendingPathComponent("results.bin")
        let moonDecl   = -19.130556    // -19°07'50"
        let uranusDecl = -18.358889    // -18°21'32"
        try writeRawRecord(
            to: resultsBinURL,
            at: 0,
            recordSize: config.recordSize,
            recordId: 1,
            isData: true,
            moonDecl: moonDecl,
            uranusDecl: uranusDecl
        )

        try file.memoryMap()

        // ── Run worker ────────────────────────────────────────────────────────────
        let orb = 0.5    // 30 arcminutes = 0.5°
        let worker = DeclMidpointsWorker(binaryFile: file, config: config, orb: orb)
        let result = try worker.run()

        // ── Assertions ────────────────────────────────────────────────────────────
        let moonUranus = result.counts.filter {
            $0.factorA == .moon && $0.factorB == .uranus
        }
        #expect(!moonUranus.isEmpty, "Expected at least one (moon, uranus, *) entry")

        let moonOccupant = moonUranus.first { $0.occupant == .moon }
        #expect(moonOccupant != nil, "(moon, uranus, moon) entry missing")
        #expect(moonOccupant?.dataCount == 1, "(moon, uranus, moon) dataCount should be 1")

        let uranusOccupant = moonUranus.first { $0.occupant == .uranus }
        #expect(uranusOccupant != nil, "(moon, uranus, uranus) entry missing")
        #expect(uranusOccupant?.dataCount == 1, "(moon, uranus, uranus) dataCount should be 1")
    }

    /// Same pair, but with orb = 0.3° (18'). Both members are 23'09" from midpoint —
    /// that exceeds this tighter orb, so no occupied triplets should be found.
    @Test("DeclMidpointsWorker does NOT find pair members when they exceed the orb")
    func testMoonUranusOutsideTightOrb() throws {
        let calcConfig = CalculationConfig()
        let calcConfigJson = String(data: try JSONEncoder().encode(calcConfig), encoding: .utf8)!

        let config = ResearchConfig(
            enabledFactorIds: [Factors.moon.rawValue, Factors.uranus.rawValue],
            inquiryId: Inquiries.declMidpoints.rawValue,
            houseSystemId: HouseSystems.placidus.rawValue,
            calculationConfigJson: calcConfigJson
        )

        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeclMidpointsWorkerTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let file = try ResultsBinaryFile.create(
            at: tmpDir.path, config: config, recordCount: 1
        )

        let resultsBinURL = tmpDir.appendingPathComponent("results.bin")
        try writeRawRecord(
            to: resultsBinURL,
            at: 0,
            recordSize: config.recordSize,
            recordId: 1,
            isData: true,
            moonDecl: -19.130556,
            uranusDecl: -18.358889
        )

        try file.memoryMap()

        // orb of 0.3° is smaller than the 0.386° distance each member has from the midpoint
        let worker = DeclMidpointsWorker(binaryFile: file, config: config, orb: 0.3)
        let result = try worker.run()

        let moonUranus = result.counts.filter {
            $0.factorA == .moon && $0.factorB == .uranus
        }
        #expect(moonUranus.isEmpty, "No (moon, uranus, *) entries expected when orb is too tight")
    }

    /// Verifies the midpoint arithmetic: a perfect occupant (a third factor at exactly the midpoint)
    /// is always found regardless of orb > 0.
    @Test("DeclMidpointsWorker finds an occupant that sits exactly on the midpoint")
    func testExactMidpointOccupant() throws {
        // Use 3 factors: moon, mercury, uranus
        // Place mercury exactly at midpoint of moon and uranus.
        let calcConfig = CalculationConfig()
        let calcConfigJson = String(data: try JSONEncoder().encode(calcConfig), encoding: .utf8)!

        let config = ResearchConfig(
            enabledFactorIds: [
                Factors.moon.rawValue,
                Factors.mercury.rawValue,
                Factors.uranus.rawValue
            ],
            inquiryId: Inquiries.declMidpoints.rawValue,
            houseSystemId: HouseSystems.placidus.rawValue,
            calculationConfigJson: calcConfigJson
        )

        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DeclMidpointsWorkerTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let file = try ResultsBinaryFile.create(
            at: tmpDir.path, config: config, recordCount: 1
        )

        let moonDecl    = -19.130556
        let uranusDecl  = -18.358889
        let mercuryDecl = (moonDecl + uranusDecl) / 2.0   // exact midpoint

        // Factor layout order (allCases filtered): moon(0), mercury(1), uranus(2)
        // Data region: moon 0-39, mercury 40-79, uranus 80-119
        let kHeaderSize = 256
        let recordSize = config.recordSize
        var bytes = [UInt8](repeating: 0, count: recordSize)
        var rid = Int64(1).littleEndian
        withUnsafeMutableBytes(of: &rid) { bytes.replaceSubrange(0..<8, with: $0) }
        bytes[8] = 1   // isData
        let dataBase = 16
        writeDoubleLE(moonDecl,    into: &bytes, at: dataBase + 8)   // moon decl
        writeDoubleLE(mercuryDecl, into: &bytes, at: dataBase + 48)  // mercury decl
        writeDoubleLE(uranusDecl,  into: &bytes, at: dataBase + 88)  // uranus decl

        let resultsBinURL = tmpDir.appendingPathComponent("results.bin")
        guard let handle = try? FileHandle(forWritingTo: resultsBinURL) else {
            Issue.record("Could not open results.bin for writing")
            return
        }
        defer { try? handle.close() }
        try handle.seek(toOffset: UInt64(kHeaderSize))
        handle.write(Data(bytes))

        try file.memoryMap()

        let worker = DeclMidpointsWorker(binaryFile: file, config: config, orb: 0.01)
        let result = try worker.run()

        // Mercury sits exactly on the midpoint of moon/uranus → should be found
        let mercuryEntry = result.counts.first {
            $0.factorA == .moon && $0.factorB == .uranus && $0.occupant == .mercury
        }
        #expect(mercuryEntry != nil, "(moon, uranus, mercury) should be found when mercury is at exact midpoint")
        #expect(mercuryEntry?.dataCount == 1)
    }
}
