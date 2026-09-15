// ExchangeMessage.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Severity of a single message produced while importing or exporting a
/// record in an exchange format. A warning never aborts the surrounding
/// record or file; a fatal error aborts only the record it belongs to.
enum ExchangeSeverity {
    case warning
    case fatal
}

/// A single diagnostic produced while parsing, mapping, importing or
/// exporting one record of an exchange format (QCK, AAF'97, Astro-Databank XML).
/// `recordNumber` is 1-based and refers to the record/line within the source
/// file; it is nil for messages that apply to the file as a whole.
struct ExchangeMessage {
    let severity: ExchangeSeverity
    let recordNumber: Int?
    let field: String?
    let message: String

    init(severity: ExchangeSeverity, recordNumber: Int? = nil, field: String? = nil, message: String) {
        self.severity = severity
        self.recordNumber = recordNumber
        self.field = field
        self.message = message
    }

    static func warning(_ message: String, recordNumber: Int? = nil, field: String? = nil) -> ExchangeMessage {
        ExchangeMessage(severity: .warning, recordNumber: recordNumber, field: field, message: message)
    }

    static func fatal(_ message: String, recordNumber: Int? = nil, field: String? = nil) -> ExchangeMessage {
        ExchangeMessage(severity: .fatal, recordNumber: recordNumber, field: field, message: message)
    }
}
