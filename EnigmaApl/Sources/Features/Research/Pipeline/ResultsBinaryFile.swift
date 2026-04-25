// ResultsBinaryFile.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Errors thrown by ResultsBinaryFile.
public enum ResultsBinaryFileError: Error {
    case cannotCreateFile(String)
    case cannotOpenFile(String)
    case cannotMapFile(String)
    case writeOutOfBounds(Int)
    case readOutOfBounds(Int)
    case invalidMagicNumber
    case versionMismatch(UInt32)
}

// MARK: - Header layout (256 bytes, fixed)
//
//  Offset  Size  Field
//  0       8     magic: "ENIGMARS" as ASCII bytes
//  8       4     version: UInt32 (currently 1)
//  12      8     recordCount: UInt64
//  20      4     recordSize: UInt32
//  24      4     factorCount: UInt32
//  28      4     coordinateFlags: UInt32  bit0=ecliptical, bit1=equatorial, bit2=horizontal
//  32      4*N   factorIds: UInt32 array (N = factorCount, max 56 = (256-32)/4)
//  ...     pad   zero-filled to 256 bytes

private let kMagic: [UInt8] = Array("ENIGMARS".utf8)
private let kVersion: UInt32 = 1
private let kHeaderSize = 256

// Per enabled coordinate system we store 5 Doubles (8 bytes each = 40 bytes):
//   mainPos, deviation, distance, speedMain, speedDeviation
private let kDoublesPerCoordSystem = 5
private let kBytesPerCoordSystem = kDoublesPerCoordSystem * 8

// Fixed prefix per record: recordId (Int64 = 8 bytes) + isData (UInt8 = 1 byte) + 7 pad bytes = 16 bytes
private let kRecordPrefix = 16

/// Creates, writes to, and memory-maps `results.bin` for a research pipeline run.
///
/// Usage pattern:
/// 1. `try ResultsBinaryFile.create(at:config:recordCount:)` — creates the file and writes the header
/// 2. `file.write(record:at:position:config:)` — called once per chart in pipeline order
/// 3. `try file.memoryMap()` — switch to read-only mmap for analysis workers
public final class ResultsBinaryFile {

    private let fileURL: URL
    private(set) var recordCount: UInt64
    private let recordSize: Int

    private var fileHandle: FileHandle?
    var mappedData: Data?

    // MARK: - Creation

    /// Creates a new `results.bin` file at `folderPath/results.bin` and writes the 256-byte header.
    /// Overwrites any existing file.
    /// - Parameters:
    ///   - folderPath: Directory where the file should be created.
    ///   - config: The research config describing which factors / coord systems are active.
    ///   - recordCount: Total number of records that will be written (needed for header and pre-allocation).
    public static func create(
        at folderPath: String,
        config: ResearchConfig,
        recordCount: UInt64
    ) throws -> ResultsBinaryFile {
        let url = URL(fileURLWithPath: folderPath, isDirectory: true)
            .appendingPathComponent("results.bin")

        let recordSize = config.recordSize
        let totalSize = kHeaderSize + Int(recordCount) * recordSize

        // Create / truncate
        guard FileManager.default.createFile(atPath: url.path, contents: nil) else {
            throw ResultsBinaryFileError.cannotCreateFile(url.path)
        }
        guard let handle = try? FileHandle(forWritingTo: url) else {
            throw ResultsBinaryFileError.cannotOpenFile(url.path)
        }
        defer { try? handle.close() }

        // Pre-allocate
        try handle.truncate(atOffset: UInt64(totalSize))
        try handle.seek(toOffset: 0)

        // Build header
        var header = [UInt8](repeating: 0, count: kHeaderSize)
        // magic
        for (i, b) in kMagic.enumerated() { header[i] = b }
        // version
        var v32 = kVersion.littleEndian
        withUnsafeMutableBytes(of: &v32) { header.replaceSubrange(8..<12, with: $0) }
        // recordCount
        var rc64 = recordCount.littleEndian
        withUnsafeMutableBytes(of: &rc64) { header.replaceSubrange(12..<20, with: $0) }
        // recordSize
        var rs32 = UInt32(recordSize).littleEndian
        withUnsafeMutableBytes(of: &rs32) { header.replaceSubrange(20..<24, with: $0) }
        // factorCount
        let factors = config.enabledFactors
        var fc32 = UInt32(factors.count).littleEndian
        withUnsafeMutableBytes(of: &fc32) { header.replaceSubrange(24..<28, with: $0) }
        // coordinateFlags
        var coordFlags: UInt32 = 0
        if config.useEcliptical  { coordFlags |= 1 }
        if config.useEquatorial  { coordFlags |= 2 }
        if config.useHorizontal  { coordFlags |= 4 }
        var cf32 = coordFlags.littleEndian
        withUnsafeMutableBytes(of: &cf32) { header.replaceSubrange(28..<32, with: $0) }
        // factor id array
        for (i, factor) in factors.enumerated() {
            let off = 32 + i * 4
            var fid = UInt32(factor.rawValue).littleEndian
            withUnsafeMutableBytes(of: &fid) { header.replaceSubrange(off..<off+4, with: $0) }
        }
        handle.write(Data(header))

        return ResultsBinaryFile(url: url, recordCount: recordCount, recordSize: recordSize)
    }

    // MARK: - Opening existing file (read)

    /// Opens an existing `results.bin` for reading/analysis.
    /// Reads `recordCount` and `recordSize` from the file header.
    /// Call `memoryMap()` after this to enable `read(at:)`.
    /// - Parameter folderPath: Directory containing `results.bin`.
    public static func open(at folderPath: String) throws -> ResultsBinaryFile {
        let url = URL(fileURLWithPath: folderPath, isDirectory: true)
            .appendingPathComponent("results.bin")
        guard let data = try? Data(contentsOf: url, options: [.mappedIfSafe]) else {
            throw ResultsBinaryFileError.cannotOpenFile(url.path)
        }
        guard data.count >= kHeaderSize else {
            throw ResultsBinaryFileError.cannotOpenFile(url.path)
        }
        // Validate magic
        let magic = Array(data[0..<8])
        guard magic == kMagic else { throw ResultsBinaryFileError.invalidMagicNumber }
        // Read version (bytes 8-11, little-endian UInt32) without alignment requirement
        let version = UInt32(data[8]) | (UInt32(data[9]) << 8) | (UInt32(data[10]) << 16) | (UInt32(data[11]) << 24)
        guard version == kVersion else { throw ResultsBinaryFileError.versionMismatch(version) }
        // Read recordCount (bytes 12-19, little-endian UInt64)
        var recordCount: UInt64 = 0
        for i in 0..<8 { recordCount |= UInt64(data[12 + i]) << (i * 8) }
        // Read recordSize (bytes 20-23, little-endian UInt32)
        let recordSize = Int(UInt32(data[20]) | (UInt32(data[21]) << 8) | (UInt32(data[22]) << 16) | (UInt32(data[23]) << 24))
        // Validate that the file is the expected size for the declared record count
        let expectedSize = kHeaderSize + Int(recordCount) * recordSize
        guard data.count == expectedSize else {
            throw ResultsBinaryFileError.cannotOpenFile(
                "\(url.path): size \(data.count) ≠ expected \(expectedSize)"
            )
        }
        var file = ResultsBinaryFile(url: url, recordCount: recordCount, recordSize: recordSize)
        file.mappedData = data
        return file
    }

    // MARK: - Init (internal)

    private init(url: URL, recordCount: UInt64, recordSize: Int) {
        self.fileURL = url
        self.recordCount = recordCount
        self.recordSize = recordSize
    }

    // MARK: - Writing

    /// Opens the file for writing (call once before the first `write`).
    public func openForWriting() throws {
        guard let handle = try? FileHandle(forWritingTo: fileURL) else {
            throw ResultsBinaryFileError.cannotOpenFile(fileURL.path)
        }
        self.fileHandle = handle
    }

    /// Writes one chart result into the binary file at the given record index.
    /// - Parameters:
    ///   - recordId: The id from the input record (copied into the binary record).
    ///   - isData: True for real data, false for control group.
    ///   - position: Zero-based index of the record in the file (0 … recordCount-1).
    ///   - coordinates: The `FullFactorPosition` map from `AstronCalcOrchestrator`.
    ///   - config: The same `ResearchConfig` used when creating the file.
    public func write(
        recordId: Int,
        isData: Bool,
        at position: Int,
        coordinates: [Factors: FullFactorPosition],
        config: ResearchConfig
    ) throws {
        guard position >= 0 && position < Int(recordCount) else {
            throw ResultsBinaryFileError.writeOutOfBounds(position)
        }
        guard let handle = fileHandle else {
            throw ResultsBinaryFileError.cannotOpenFile(fileURL.path)
        }

        var record = [UInt8](repeating: 0, count: recordSize)

        // Prefix: recordId (Int64 LE) at byte 0, isData (UInt8) at byte 8, 7 pad bytes
        var rid = Int64(recordId).littleEndian
        withUnsafeMutableBytes(of: &rid) { record.replaceSubrange(0..<8, with: $0) }
        record[8] = isData ? 1 : 0

        // Data region starts at byte kRecordPrefix (16)
        var byteOffset = kRecordPrefix
        let layouts = config.factorLayouts

        for layout in layouts {
            guard let pos = coordinates[layout.factor] else {
                // Factor not calculated — leave the bytes as zeros and skip ahead
                byteOffset += layout.byteSize
                continue
            }
            // Always advance byteOffset by the full slot size, even if the
            // position array is empty (no .first), to keep the layout in sync.
            if layout.hasEcliptical {
                if let ecl = pos.ecliptical.first {
                    byteOffset = writeCoord(ecl, into: &record, at: byteOffset)
                } else {
                    byteOffset += kBytesPerCoordSystem
                }
            }
            if layout.hasEquatorial {
                if let eq = pos.equatorial.first {
                    byteOffset = writeCoord(eq, into: &record, at: byteOffset)
                } else {
                    byteOffset += kBytesPerCoordSystem
                }
            }
            if layout.hasHorizontal {
                if let hz = pos.horizontal.first {
                    byteOffset = writeHorizontal(hz, into: &record, at: byteOffset)
                } else {
                    byteOffset += kBytesPerCoordSystem
                }
            }
        }

        let fileOffset = UInt64(kHeaderSize + position * recordSize)
        try handle.seek(toOffset: fileOffset)
        handle.write(Data(record))
    }

    /// Closes the write handle. Call after all records have been written.
    public func closeForWriting() {
        try? fileHandle?.close()
        fileHandle = nil
    }

    // MARK: - Memory mapping (read)

    /// Switches the file to read-only memory-mapped mode.
    /// Call this after writing is complete, before any analysis reads.
    public func memoryMap() throws {
        guard let data = try? Data(
            contentsOf: fileURL,
            options: [.mappedIfSafe, .alwaysMapped]
        ) else {
            throw ResultsBinaryFileError.cannotMapFile(fileURL.path)
        }
        // Validate magic
        guard data.count >= kHeaderSize else { throw ResultsBinaryFileError.cannotMapFile(fileURL.path) }
        let magic = Array(data[0..<8])
        guard magic == kMagic else { throw ResultsBinaryFileError.invalidMagicNumber }
        self.mappedData = data
    }

    /// Reads one record from the memory-mapped file.
    /// Returns `(recordId, isData, rawDataBytes)` where rawDataBytes is the data region.
    public func read(at position: Int) throws -> (recordId: Int, isData: Bool, data: Data) {
        guard let mapped = mappedData else {
            throw ResultsBinaryFileError.cannotMapFile(fileURL.path)
        }
        guard position >= 0 && position < Int(recordCount) else {
            throw ResultsBinaryFileError.readOutOfBounds(position)
        }
        let start = kHeaderSize + position * recordSize
        let end = start + recordSize
        guard end <= mapped.count else {
            throw ResultsBinaryFileError.readOutOfBounds(position)
        }
        guard recordSize >= kRecordPrefix else {
            throw ResultsBinaryFileError.readOutOfBounds(position)
        }

        // Copy record bytes into a fresh buffer — avoids working with Data subrange indices
        let recordBytes = Data(mapped[start..<end])

        // Read recordId as 8 little-endian bytes without alignment requirement
        var rid: Int64 = 0
        for i in 0..<8 {
            rid |= Int64(bitPattern: UInt64(recordBytes[i])) << (i * 8)
        }
        let recordId = Int(rid)
        let isData = recordBytes[8] != 0
        let dataRegion = recordBytes[kRecordPrefix..<recordSize]

        return (recordId: recordId, isData: isData, data: Data(dataRegion))
    }

    // MARK: - Coordinate helpers

    /// Writes one `Double` as 8 little-endian bytes into `buffer` at `offset`.
    private func writeDouble(_ value: Double, into buffer: inout [UInt8], at offset: Int) {
        var le = value.bitPattern.littleEndian   // UInt64
        withUnsafeMutableBytes(of: &le) { src in
            buffer.replaceSubrange(offset..<offset + 8, with: src)
        }
    }

    /// Writes 5 Doubles (mainPos, deviation, distance, speedMain, speedDeviation) into the buffer.
    private func writeCoord(
        _ pos: MainAstronomicalPosition,
        into buffer: inout [UInt8],
        at offset: Int
    ) -> Int {
        var o = offset
        writeDouble(pos.mainPos,       into: &buffer, at: o); o += 8
        writeDouble(pos.deviation,     into: &buffer, at: o); o += 8
        writeDouble(pos.distance,      into: &buffer, at: o); o += 8
        writeDouble(pos.mainPosSpeed,  into: &buffer, at: o); o += 8
        writeDouble(pos.deviationSpeed,into: &buffer, at: o); o += 8
        return o
    }

    /// Writes 2 Doubles (azimuth, altitude) for horizontal — padded to 5 doubles (40 bytes) for uniform record size.
    private func writeHorizontal(
        _ pos: HorizontalPosition,
        into buffer: inout [UInt8],
        at offset: Int
    ) -> Int {
        var o = offset
        writeDouble(pos.azimuth,  into: &buffer, at: o); o += 8
        writeDouble(pos.altitude, into: &buffer, at: o); o += 8
        writeDouble(0.0,          into: &buffer, at: o); o += 8
        writeDouble(0.0,          into: &buffer, at: o); o += 8
        writeDouble(0.0,          into: &buffer, at: o); o += 8
        return o
    }
}
