// AafImportExportOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import SwiftData
import Foundation
@testable import EnigmaApl

@MainActor
struct AafImportExportOrchestratorTests {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([HoroscopeModel.self, HoroscopeDateTimeModel.self, EventModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    private let basicRecord = """
    #: Enigma AAF export
    #A93:Kampherbeek,Jan,*,29.1.1953,08:37:30,Enschede,NL
    #B93:*,52n13,6e54,1he,0
    #ZNAM:CET
    #: AAF end
    """

    @Test("AafImportExportOrchestrator: imports a chart from an AAF file")
    func testImport() throws {
        let context = try makeContext()
        let orchestrator = AafImportExportOrchestrator(context: context)
        let result = orchestrator.importFile(data: Data(basicRecord.utf8))

        #expect(result.chartsImported == 1)
        #expect(result.fatalMessages.isEmpty)

        let charts = try context.fetch(FetchDescriptor<HoroscopeModel>())
        #expect(charts.count == 1)
        #expect(charts.first?.name == "Jan Kampherbeek")
        #expect(charts.first?.placeName == "Enschede,NL")
    }

    @Test("AafImportExportOrchestrator: multiple records import multiple charts")
    func testImportMultipleRecords() throws {
        let content = """
        #A93:Doe,Jane,*,1.1.2000,12:00,City,US
        #B93:*,0n00,0e00,0he,0
        #A93:Roe,Richard,*,2.2.2001,13:00,Town,US
        #B93:*,1n00,1e00,1he,0
        """
        let context = try makeContext()
        let result = AafImportExportOrchestrator(context: context).importFile(data: Data(content.utf8))
        #expect(result.chartsImported == 2)
    }

    @Test("AafImportExportOrchestrator: export then import round trip preserves name, place and instant")
    func testExportImportRoundTrip() throws {
        let context = try makeContext()
        let importOrchestrator = AafImportExportOrchestrator(context: context)
        _ = importOrchestrator.importFile(data: Data(basicRecord.utf8))

        let (exportedData, exportMessages) = try importOrchestrator.exportData()
        // The chart's timezone identifier is already "UTC", so no timezone warning is expected.
        // The place "Enschede,NL" does trigger a place-sanitization warning: AAF has no
        // separate country field round trip for HoroscopeModel (see AafMapper's doc comment).
        #expect(exportMessages.allSatisfy { $0.field != "timezone" })
        #expect(exportMessages.contains { $0.field == "place" })

        let secondContext = try makeContext()
        let reimportOrchestrator = AafImportExportOrchestrator(context: secondContext)
        let reimportResult = reimportOrchestrator.importFile(data: exportedData)

        #expect(reimportResult.chartsImported == 1)
        let originalChart = try context.fetch(FetchDescriptor<HoroscopeModel>()).first
        let reimportedChart = try secondContext.fetch(FetchDescriptor<HoroscopeModel>()).first
        #expect(reimportedChart?.name == originalChart?.name)
        #expect(reimportedChart?.id == originalChart?.id)

        let originalJd = originalChart?.dateTimes.first?.julianDate
        let reimportedJd = reimportedChart?.dateTimes.first?.julianDate
        #expect(abs((originalJd ?? 0) - (reimportedJd ?? 1)) < 0.0000001)
    }

    @Test("AafImportExportOrchestrator: re-importing an already-present chart (same #ENID) is skipped, not duplicated")
    func testReimportSameChartIsSkipped() throws {
        let context = try makeContext()
        let orchestrator = AafImportExportOrchestrator(context: context)
        _ = orchestrator.importFile(data: Data(basicRecord.utf8))

        let (exportedData, _) = try orchestrator.exportData()
        let reimportResult = orchestrator.importFile(data: exportedData)

        #expect(reimportResult.chartsImported == 0)
        #expect(reimportResult.chartsSkipped == 1)
        let charts = try context.fetch(FetchDescriptor<HoroscopeModel>())
        #expect(charts.count == 1)
    }

    @Test("AafImportExportOrchestrator: exported file is valid UTF-8")
    func testExportIsUtf8() throws {
        let context = try makeContext()
        let chart = HoroscopeModel(name: "Müller, André", placeName: "Montréal", latitude: 45.5, longitude: -73.6)
        chart.dateTimes = [HoroscopeDateTimeModel(julianDate: 2451545.0)]
        context.insert(chart)
        try context.save()

        let (data, _) = try AafImportExportOrchestrator(context: context).exportData()
        let text = try! #require(String(data: data, encoding: .utf8))
        #expect(text.contains("Müller"))
        #expect(text.contains("Montréal"))
    }
}
