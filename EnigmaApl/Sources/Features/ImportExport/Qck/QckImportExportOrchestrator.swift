// QckImportExportOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Builds and applies the QCK import/export format for charts. Charts are
/// the only thing QCK can represent (no events). A problem in one record
/// never aborts the whole file: it is reported as a warning or fatal message
/// scoped to that record, and the remaining records are still processed.
///
/// All methods run on the main actor because ModelContext is not Sendable,
/// matching `EnigmaImportExportOrchestrator`.
@MainActor
struct QckImportExportOrchestrator {

    private let context: ModelContext
    private let seWrapper = SEWrapper()

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Import

    func importFile(data: Data, legacyEncoding: String.Encoding = LegacyTextEncoding.defaultLegacyEncoding) -> FormatImportResult {
        var result = FormatImportResult()

        let decoded = LegacyTextEncoding.decode(data, legacyEncoding: legacyEncoding)
        result.messages.append(contentsOf: decoded.messages)

        let parseResult = QckFileParser.parse(content: decoded.content)
        result.messages.append(contentsOf: parseResult.messages)

        for (index, record) in parseResult.records.enumerated() {
            let recordNumber = index + 1
            let (mapped, messages) = QckMapper.toMappedChart(record: record, recordNumber: recordNumber, seWrapper: seWrapper)
            result.messages.append(contentsOf: messages)

            let dateTime = HoroscopeDateTimeModel(
                julianDate: mapped.julianDate,
                timeZoneIdentifier: "UTC",
                timeIsUnknown: false,
                isPreferred: true,
                originalInput: mapped.originalInput
            )
            let chart = HoroscopeModel(
                name: mapped.name,
                placeName: mapped.placeName,
                latitude: mapped.latitude,
                longitude: mapped.longitude
            )
            chart.dateTimes = [dateTime]
            context.insert(chart)
            result.chartsImported += 1
        }

        do {
            try context.save()
        } catch {
            result.messages.append(.fatal("Failed to save imported charts: \(error.localizedDescription)"))
        }
        return result
    }

    // MARK: - Export

    /// Exports all charts as QCK records, one per line, CRLF-terminated
    /// (the traditional line ending for this legacy DOS-era format).
    func exportData(legacyEncoding: String.Encoding = LegacyTextEncoding.defaultLegacyEncoding) throws -> (data: Data, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []
        let charts = try context.fetch(FetchDescriptor<HoroscopeModel>(sortBy: [SortDescriptor(\.name)]))

        var lines: [String] = []
        var recordNumber = 0
        for chart in charts {
            guard let dateTime = chart.dateTimes.first(where: { $0.isPreferred }) ?? chart.dateTimes.first else {
                messages.append(.warning("Chart '\(chart.name)' has no date/time and was skipped.", field: "dateTime"))
                continue
            }
            guard let latitude = chart.latitude, let longitude = chart.longitude else {
                messages.append(.warning("Chart '\(chart.name)' has no coordinates and was skipped.", field: "coordinates"))
                continue
            }
            recordNumber += 1

            let (record, mapMessages) = QckMapper.toRecord(
                name: chart.name,
                placeName: chart.placeName,
                latitude: latitude,
                longitude: longitude,
                julianDate: dateTime.julianDate,
                timeZoneIdentifier: dateTime.timeZoneIdentifier,
                recordNumber: recordNumber,
                seWrapper: seWrapper
            )
            messages.append(contentsOf: mapMessages)

            let (line, writeMessages) = QckWriter.write(record: record, recordNumber: recordNumber)
            messages.append(contentsOf: writeMessages)
            if let line {
                lines.append(line)
            }
        }

        let text = lines.isEmpty ? "" : lines.joined(separator: "\r\n") + "\r\n"
        let (data, hadLoss) = LegacyTextEncoding.encode(text, legacyEncoding: legacyEncoding)
        if hadLoss {
            messages.append(.warning("Some characters could not be represented in the legacy export encoding and were replaced."))
        }
        return (data, messages)
    }
}
