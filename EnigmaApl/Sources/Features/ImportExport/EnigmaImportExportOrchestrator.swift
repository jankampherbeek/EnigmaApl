// EnigmaImportExportOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Result of an Enigma-format import: how many charts and events were newly
/// created versus skipped because their id already existed locally.
struct EnigmaImportResult {
    var chartsImported = 0
    var chartsSkipped = 0
    var eventsImported = 0
    var eventsSkipped = 0
}

/// Builds and applies the Enigma JSON import/export format for charts and events.
/// Import skips any chart or event whose id already exists locally, leaving the
/// local record untouched.
///
/// All methods run on the main actor because ModelContext is not Sendable.
@MainActor
struct EnigmaImportExportOrchestrator {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Export

    func buildExportFile() throws -> EnigmaExportFile {
        let charts = try context.fetch(FetchDescriptor<HoroscopeModel>())
        let events = try context.fetch(FetchDescriptor<EventModel>())

        let chartDTOs = charts.map { chart in
            EnigmaChartDTO(
                id: chart.id,
                name: chart.name,
                category: chart.category,
                notes: chart.notes,
                source: chart.source,
                roddenRating: chart.roddenRating,
                placeName: chart.placeName,
                latitude: chart.latitude,
                longitude: chart.longitude,
                dateTimes: chart.dateTimes.map { dateTime in
                    EnigmaDateTimeDTO(
                        id: dateTime.id,
                        julianDate: dateTime.julianDate,
                        timeZoneIdentifier: dateTime.timeZoneIdentifier,
                        timeIsUnknown: dateTime.timeIsUnknown,
                        isPreferred: dateTime.isPreferred,
                        label: dateTime.label,
                        originalInput: dateTime.originalInput
                    )
                }
            )
        }

        let eventDTOs = events.map { event in
            EnigmaEventDTO(
                id: event.id,
                title: event.title,
                eventDescription: event.eventDescription,
                julianDate: event.julianDate,
                timeZoneIdentifier: event.timeZoneIdentifier,
                originalInput: event.originalInput,
                placeName: event.placeName,
                latitude: event.latitude,
                longitude: event.longitude,
                country: event.country,
                location: event.location,
                chartIds: event.horoscopes.map(\.id)
            )
        }

        return EnigmaExportFile(
            formatVersion: EnigmaExportFile.currentFormatVersion,
            exportedAt: Date(),
            charts: chartDTOs,
            events: eventDTOs
        )
    }

    // MARK: - Import

    /// Imports charts and events from the given file. A chart or event whose id
    /// already exists locally is skipped; existing local data is never overwritten.
    func importFile(_ file: EnigmaExportFile) throws -> EnigmaImportResult {
        var result = EnigmaImportResult()

        var chartsById: [UUID: HoroscopeModel] = [:]
        for chart in try context.fetch(FetchDescriptor<HoroscopeModel>()) {
            chartsById[chart.id] = chart
        }
        let existingEventIds = Set(try context.fetch(FetchDescriptor<EventModel>()).map(\.id))

        for chartDTO in file.charts {
            guard chartsById[chartDTO.id] == nil else {
                result.chartsSkipped += 1
                continue
            }
            let chart = HoroscopeModel(
                name: chartDTO.name,
                category: chartDTO.category,
                notes: chartDTO.notes,
                source: chartDTO.source,
                roddenRating: chartDTO.roddenRating,
                placeName: chartDTO.placeName,
                latitude: chartDTO.latitude,
                longitude: chartDTO.longitude
            )
            chart.id = chartDTO.id
            chart.dateTimes = chartDTO.dateTimes.map { dateTimeDTO in
                let dateTime = HoroscopeDateTimeModel(
                    julianDate: dateTimeDTO.julianDate,
                    timeZoneIdentifier: dateTimeDTO.timeZoneIdentifier,
                    timeIsUnknown: dateTimeDTO.timeIsUnknown,
                    isPreferred: dateTimeDTO.isPreferred,
                    label: dateTimeDTO.label,
                    originalInput: dateTimeDTO.originalInput
                )
                dateTime.id = dateTimeDTO.id
                return dateTime
            }
            context.insert(chart)
            chartsById[chart.id] = chart
            result.chartsImported += 1
        }

        for eventDTO in file.events {
            guard !existingEventIds.contains(eventDTO.id) else {
                result.eventsSkipped += 1
                continue
            }
            let event = EventModel(
                title: eventDTO.title,
                eventDescription: eventDTO.eventDescription,
                julianDate: eventDTO.julianDate,
                timeZoneIdentifier: eventDTO.timeZoneIdentifier,
                originalInput: eventDTO.originalInput,
                placeName: eventDTO.placeName,
                latitude: eventDTO.latitude,
                longitude: eventDTO.longitude,
                country: eventDTO.country,
                location: eventDTO.location
            )
            event.id = eventDTO.id
            event.horoscopes = eventDTO.chartIds.compactMap { chartsById[$0] }
            context.insert(event)
            result.eventsImported += 1
        }

        try context.save()
        return result
    }
}
