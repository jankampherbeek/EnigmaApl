// QckImportExportOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import SwiftData
import Foundation
@testable import EnigmaApl

@MainActor
struct QckImportExportOrchestratorTests {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([HoroscopeModel.self, HoroscopeDateTimeModel.self, EventModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    private let fixture = "JK                     JAN 29, 195308:37:30 AM    -01:00006E54'00 52N13'00 Enschede,Netherlands     "

    @Test("QckImportExportOrchestrator: imports a chart from a QCK file")
    func testImport() throws {
        let context = try makeContext()
        let orchestrator = QckImportExportOrchestrator(context: context)
        let data = Data(fixture.utf8)

        let result = orchestrator.importFile(data: data)

        #expect(result.chartsImported == 1)
        #expect(result.fatalMessages.isEmpty)

        let charts = try context.fetch(FetchDescriptor<HoroscopeModel>())
        #expect(charts.count == 1)
        #expect(charts.first?.name == "JK")
        #expect(charts.first?.placeName == "Enschede,Netherlands")
        #expect(charts.first?.dateTimes.first?.timeZoneIdentifier == "UTC")
    }

    @Test("QckImportExportOrchestrator: a fatal record error does not block the rest of the import")
    func testImportContinuesAfterFatalRecord() throws {
        let context = try makeContext()
        let orchestrator = QckImportExportOrchestrator(context: context)
        let badLine = String(repeating: "X", count: 90)
        let data = Data((fixture + "\n" + badLine + "\n" + fixture).utf8)

        let result = orchestrator.importFile(data: data)

        #expect(result.chartsImported == 2)
        #expect(result.fatalMessages.count == 1)
    }

    @Test("QckImportExportOrchestrator: export then import round trip preserves name, place, coordinates and instant")
    func testExportImportRoundTrip() throws {
        let context = try makeContext()
        let importOrchestrator = QckImportExportOrchestrator(context: context)
        _ = importOrchestrator.importFile(data: Data(fixture.utf8))

        let (exportedData, exportMessages) = try importOrchestrator.exportData()
        #expect(exportMessages.isEmpty) // timezone identifier is "UTC" already, nothing lost

        let secondContext = try makeContext()
        let reimportOrchestrator = QckImportExportOrchestrator(context: secondContext)
        let reimportResult = reimportOrchestrator.importFile(data: exportedData)

        #expect(reimportResult.chartsImported == 1)
        let reimportedChart = try secondContext.fetch(FetchDescriptor<HoroscopeModel>()).first
        #expect(reimportedChart?.name == "JK")
        #expect(reimportedChart?.placeName == "Enschede,Netherlands")

        let originalChart = try context.fetch(FetchDescriptor<HoroscopeModel>()).first
        let originalJd = originalChart?.dateTimes.first?.julianDate
        let reimportedJd = reimportedChart?.dateTimes.first?.julianDate
        #expect(abs((originalJd ?? 0) - (reimportedJd ?? 1)) < 0.0000001)
    }

    @Test("QckImportExportOrchestrator: export skips charts without coordinates and warns")
    func testExportSkipsIncompleteCharts() throws {
        let context = try makeContext()
        let chart = HoroscopeModel(name: "No Coordinates")
        chart.dateTimes = [HoroscopeDateTimeModel(julianDate: 2451545.0)]
        context.insert(chart)
        try context.save()

        let orchestrator = QckImportExportOrchestrator(context: context)
        let (data, messages) = try orchestrator.exportData()

        #expect(data.isEmpty || String(data: data, encoding: .windowsCP1252) == "")
        #expect(messages.contains { $0.severity == .warning && $0.field == "coordinates" })
    }
}
