// FormatImportResult.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Outcome of parsing a whole exchange-format file into format-specific
/// intermediate records, before mapping to the Enigma domain model. A record
/// with a fatal error is left out of `records`; parsing continues with the
/// remaining records rather than aborting the file.
struct FormatParseResult<Record> {
    var records: [Record] = []
    var messages: [ExchangeMessage] = []

    var fatalMessages: [ExchangeMessage] { messages.filter { $0.severity == .fatal } }
    var warningMessages: [ExchangeMessage] { messages.filter { $0.severity == .warning } }
}

/// Outcome of importing parsed records into the Enigma domain model.
/// Mirrors `EnigmaImportResult`'s counters, extended with per-record
/// warnings/fatal errors so a problem in one record does not have to abort
/// the whole import.
struct FormatImportResult {
    var chartsImported = 0
    var chartsSkipped = 0
    var eventsImported = 0
    var eventsSkipped = 0
    var messages: [ExchangeMessage] = []

    var fatalMessages: [ExchangeMessage] { messages.filter { $0.severity == .fatal } }
    var warningMessages: [ExchangeMessage] { messages.filter { $0.severity == .warning } }
}
