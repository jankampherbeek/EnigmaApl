// AdbXmlImportOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Builds and applies the Astro-Databank XML import for charts. Import-only.
/// A problem in one entry never aborts the whole file: it is reported as a
/// warning or fatal message scoped to that entry, and the remaining entries
/// are still processed. A malformed XML document itself is a file-level
/// fatal error, since XMLParser cannot resume after that.
///
/// All methods run on the main actor because ModelContext is not Sendable,
/// matching `EnigmaImportExportOrchestrator`.
@MainActor
struct AdbXmlImportOrchestrator {

    private let context: ModelContext
    private let seWrapper = SEWrapper()

    init(context: ModelContext) {
        self.context = context
    }

    func importFile(data: Data) -> FormatImportResult {
        var result = FormatImportResult()

        let parseResult = AdbXmlParser.parse(data: data)
        result.messages.append(contentsOf: parseResult.messages)

        for (index, record) in parseResult.records.enumerated() {
            let recordNumber = index + 1
            let (mapped, messages) = AdbXmlMapper.toMappedChart(record: record, recordNumber: recordNumber, seWrapper: seWrapper)
            result.messages.append(contentsOf: messages)
            guard !messages.contains(where: { $0.severity == .fatal }) else { continue }

            let dateTime = HoroscopeDateTimeModel(
                julianDate: mapped.julianDate,
                timeZoneIdentifier: "UTC",
                timeIsUnknown: mapped.timeIsUnknown,
                isPreferred: true,
                originalInput: mapped.originalInput
            )
            let chart = HoroscopeModel(
                name: mapped.name,
                category: mapped.category,
                notes: mapped.notes,
                roddenRating: mapped.roddenRating,
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
}
