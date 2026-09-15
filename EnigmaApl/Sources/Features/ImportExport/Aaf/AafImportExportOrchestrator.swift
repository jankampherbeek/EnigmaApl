// AafImportExportOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Builds and applies the AAF'97 import/export format for charts. Every
/// AAF record becomes a `HoroscopeModel` (see `AafMapper`'s doc comment for
/// why events are not created). A problem in one record never aborts the
/// whole file: it is reported as a warning or fatal message scoped to that
/// record, and the remaining records are still processed.
///
/// All methods run on the main actor because ModelContext is not Sendable,
/// matching `EnigmaImportExportOrchestrator`.
@MainActor
struct AafImportExportOrchestrator {

    private let context: ModelContext
    private let seWrapper = SEWrapper()

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Import

    func importFile(data: Data, legacyEncoding: String.Encoding = LegacyTextEncoding.defaultLegacyEncoding) -> FormatImportResult {
        var result = FormatImportResult()

        let decoded = LegacyTextEncoding.decodePreferringUtf8(data, legacyEncoding: legacyEncoding)
        result.messages.append(contentsOf: decoded.messages)

        let parseResult = AafRecordParser.parse(content: decoded.content)
        result.messages.append(contentsOf: parseResult.messages)

        for (index, record) in parseResult.records.enumerated() {
            let recordNumber = index + 1
            let (mapped, messages) = AafMapper.toMappedChart(record: record, recordNumber: recordNumber, seWrapper: seWrapper)
            result.messages.append(contentsOf: messages)
            guard !messages.contains(where: { $0.severity == .fatal }) else { continue }

            let dateTime = HoroscopeDateTimeModel(
                julianDate: mapped.julianDate,
                timeZoneIdentifier: "UTC",
                timeIsUnknown: false,
                isPreferred: true,
                originalInput: mapped.originalInput
            )
            let chart = HoroscopeModel(
                name: mapped.name,
                category: mapped.category,
                notes: mapped.notes,
                source: mapped.source,
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

    /// Exports all charts as AAF'97 records, UTF-8 encoded, separated by a
    /// blank line, each preceded by a "#:" comment naming the source chart.
    func exportData() throws -> (data: Data, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []
        let charts = try context.fetch(FetchDescriptor<HoroscopeModel>(sortBy: [SortDescriptor(\.name)]))

        var blocks: [String] = []
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

            let (record, mapMessages) = AafMapper.toRecord(
                name: chart.name,
                category: chart.category,
                source: chart.source,
                notes: chart.notes,
                placeName: chart.placeName,
                latitude: latitude,
                longitude: longitude,
                julianDate: dateTime.julianDate,
                timeZoneIdentifier: dateTime.timeZoneIdentifier,
                recordNumber: recordNumber,
                seWrapper: seWrapper
            )
            messages.append(contentsOf: mapMessages)

            let (text, writeMessages) = AafWriter.write(record: record, recordNumber: recordNumber)
            messages.append(contentsOf: writeMessages)
            blocks.append(text)
        }

        let text = blocks.joined(separator: "\n\n")
        return (Data(text.utf8), messages)
    }
}
