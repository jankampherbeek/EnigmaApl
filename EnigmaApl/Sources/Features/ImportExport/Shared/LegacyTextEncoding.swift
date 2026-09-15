// LegacyTextEncoding.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Several exchange formats (QCK, AAF'97) predate any modern Unicode
/// standard, so encoding is never a hidden platform default.
///
/// Import accepts a configurable legacy single-byte encoding (defaulting to
/// Windows-1252) but is tolerant of files that were actually saved as UTF-8:
/// when the bytes decode as valid UTF-8 *and* that UTF-8 text is pure ASCII
/// (so byte count equals character count, meaning any fixed-width positional
/// offsets still line up), the UTF-8 reading is used without a warning. Any
/// other case decodes with the legacy encoding and reports a warning, since
/// the true encoding cannot be confirmed.
///
/// Export helpers here write one explicit legacy single-byte encoding
/// (Windows-1252) for formats that need it (QCK); AAF'97 always exports
/// as UTF-8 and does not use the `encode(_:)` helper below.
enum LegacyTextEncoding {

    static let defaultLegacyEncoding: String.Encoding = .windowsCP1252

    struct DecodedFile {
        let content: String
        let messages: [ExchangeMessage]
    }

    static func decode(_ data: Data, legacyEncoding: String.Encoding = defaultLegacyEncoding) -> DecodedFile {
        if let utf8Text = String(data: data, encoding: .utf8), utf8Text.utf8.count == utf8Text.count {
            // Pure ASCII: identical under UTF-8 and any single-byte legacy encoding.
            return DecodedFile(content: utf8Text, messages: [])
        }
        if let legacyText = String(data: data, encoding: legacyEncoding) {
            return DecodedFile(content: legacyText, messages: [
                .warning("File encoding could not be confirmed; decoded using \(name(for: legacyEncoding)).")
            ])
        }
        // Fall back to lossy legacy decoding rather than failing outright.
        let lossyText = String(decoding: data, as: UTF8.self)
        return DecodedFile(content: lossyText, messages: [
            .warning("File could not be decoded as \(name(for: legacyEncoding)); fell back to a lossy UTF-8 reading.")
        ])
    }

    /// Encodes `text` using the explicit legacy encoding. Characters that
    /// cannot be represented are replaced (lossy conversion) and reported.
    static func encode(_ text: String, legacyEncoding: String.Encoding = defaultLegacyEncoding) -> (data: Data, hadLoss: Bool) {
        if let strict = text.data(using: legacyEncoding, allowLossyConversion: false) {
            return (strict, false)
        }
        let lossy = text.data(using: legacyEncoding, allowLossyConversion: true) ?? Data(text.utf8)
        return (lossy, true)
    }

    /// Decodes formats that are not fixed-width (AAF'97), so full UTF-8 text
    /// (accented characters included, e.g. "Montréal") is always tried first
    /// rather than only the pure-ASCII fast path `decode(_:)` uses to protect
    /// fixed-width column offsets.
    static func decodePreferringUtf8(_ data: Data, legacyEncoding: String.Encoding = defaultLegacyEncoding) -> DecodedFile {
        if let utf8Text = String(data: data, encoding: .utf8) {
            return DecodedFile(content: utf8Text, messages: [])
        }
        if let legacyText = String(data: data, encoding: legacyEncoding) {
            return DecodedFile(content: legacyText, messages: [
                .warning("File is not valid UTF-8; decoded using \(name(for: legacyEncoding)).")
            ])
        }
        let lossyText = String(decoding: data, as: UTF8.self)
        return DecodedFile(content: lossyText, messages: [
            .warning("File could not be decoded as UTF-8 or \(name(for: legacyEncoding)); fell back to a lossy UTF-8 reading.")
        ])
    }

    private static func name(for encoding: String.Encoding) -> String {
        switch encoding {
        case .windowsCP1252: return "Windows-1252"
        case .isoLatin1: return "ISO-8859-1"
        default: return "the configured legacy encoding"
        }
    }
}
