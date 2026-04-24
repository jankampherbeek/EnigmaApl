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
        withUnsafeBytes(of: kVersion.littleEndian) { bytes in
            header.replaceSubrange(8..<12, with: bytes)
        }
        // recordCount
        withUnsafeBytes(of: recordCount.littleEndian) { bytes in
            header.replaceSubrange(12..<20, with: bytes)
        }
        // recordSize
        withUnsafeBytes(of: UInt32(recordSize).littleEndian) { bytes in
            header.replaceSubrange(20..<24, with: bytes)
        }
        // factorIds
        let factors = config.enabledFactors
        withUnsafeBytes(of: UInt32(factors.count).littleEndian) { bytes in
            header.replaceSubrange(24..<28, with: bytes)
        }
        // coordinateFlags
        var coordFlags: UInt32 = 0
        if config.useEcliptical  { coordFlags |= 1 }
        if config.useEquatorial  { coordFlags |= 2 }
        if config.useHorizontal  { coordFlags |= 4 }
        withUnsafeBytes(of: coordFlags.littleEndian) { bytes in
            header.replaceSubrange(28..<32, with: bytes)
        }
        // factor id array
        for (i, factor) in factors.enumerated() {
            let offset = 32 + i * 4
            withUnsafeBytes(of: UInt32(factor.rawValue).littleEndian) { bytes in
                header.replaceSubrange(offset..<offset+4, with: bytes)
            }
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
        // Read version
        let version = data.withUnsafeBytes { ptr in
            ptr.load(fromByteOffset: 8, as: UInt32.self).littleEndian
        }
        guard version == kVersion else { throw ResultsBinaryFileError.versionMismatch(version) }
        // Read recordCount and recordSize from header
        let recordCount = data.withUnsafeBytes { ptr in
            ptr.load(fromByteOffset: 12, as: UInt64.self).littleEndian
        }
        let recordSize = Int(data.withUnsafeBytes { ptr in
            ptr.load(fromByteOffset: 20, as: UInt32.self).littleEndian
        })
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
        withUnsafeBytes(of: Int64(recordId).littleEndian) { bytes in
            record.replaceSubrange(0..<8, with: bytes)
        }
        record[8] = isData ? 1 : 0

        // Data region starts at byte kRecordPrefix (16)
        var byteOffset = kRecordPrefix
        let layouts = config.factorLayouts

        for layout in layouts {
            guard let pos = coordinates[layout.factor] else {
                byteOffset += layout.byteSize
                continue
            }
            if layout.hasEcliptical, let ecl = pos.ecliptical.first {
                byteOffset = writeCoord(ecl, into: &record, at: byteOffset)
            }
            if layout.hasEquatorial, let eq = pos.equatorial.first {
                byteOffset = writeCoord(eq, into: &record, at: byteOffset)
            }
            if layout.hasHorizontal, let hz = pos.horizontal.first {
                byteOffset = writeHorizontal(hz, into: &record, at: byteOffset)
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

        let slice = mapped[start..<end]

        let recordId = slice.withUnsafeBytes { ptr in
            Int(ptr.load(as: Int64.self).littleEndian)
        }
        let isData = slice[start + 8] != 0
        let dataRegion = slice[(start + kRecordPrefix)..<end]

        return (recordId: recordId, isData: isData, data: Data(dataRegion))
    }

    // MARK: - Coordinate helpers

    /// Writes 5 Doubles (mainPos, deviation, distance, speedMain, speedDeviation) into the buffer.
    private func writeCoord(
        _ pos: MainAstronomicalPosition,
        into buffer: inout [UInt8],
        at offset: Int
    ) -> Int {
        var o = offset
        let values = [pos.mainPos, pos.deviation, pos.distance, pos.mainPosSpeed, pos.deviationSpeed]
        for v in values {
            withUnsafeBytes(of: v.bitPattern.littleEndian) { bytes in
                buffer.replaceSubrange(o..<o+8, with: bytes)
            }
            o += 8
        }
        return o
    }

    /// Writes 2 Doubles (azimuth, altitude) for horizontal — padded to 5 doubles (40 bytes) for uniform record size.
    private func writeHorizontal(
        _ pos: HorizontalPosition,
        into buffer: inout [UInt8],
        at offset: Int
    ) -> Int {
        var o = offset
        let values = [pos.azimuth, pos.altitude, 0.0, 0.0, 0.0]
        for v in values {
            withUnsafeBytes(of: v.bitPattern.littleEndian) { bytes in
                buffer.replaceSubrange(o..<o+8, with: bytes)
            }
            o += 8
        }
        return o
    }
}
