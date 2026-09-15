// AdbXmlImportOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import SwiftData
import Foundation
@testable import EnigmaApl

@MainActor
struct AdbXmlImportOrchestratorTests {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([HoroscopeModel.self, HoroscopeDateTimeModel.self, EventModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    private let fixture = """
    <?xml version="1.0" encoding="UTF-8"?>
    <astrodatabank_export export_format="160715">
      <adb_entry adb_id="73001">
        <public_data>
          <name>Grayson, Larry</name>
          <sflname>Larry Grayson</sflname>
          <gender csex="m">M</gender>
          <roddenrating rrc="1">AA</roddenrating>
          <sbdate ccalendar="g" iyear="1953" imonth="1" iday="29">1953/01/29</sbdate>
          <sbtime ctimetype="s" stmerid="h1e">08:37:30</sbtime>
          <place slati="52n13" slong="6e54">Enschede</place>
          <country sctr="NL">Netherlands</country>
        </public_data>
      </adb_entry>
    </astrodatabank_export>
    """

    @Test("AdbXmlImportOrchestrator: imports a chart from Astro-Databank XML")
    func testImport() throws {
        let context = try makeContext()
        let result = AdbXmlImportOrchestrator(context: context).importFile(data: Data(fixture.utf8))

        #expect(result.chartsImported == 1)
        #expect(result.fatalMessages.isEmpty)

        let chart = try context.fetch(FetchDescriptor<HoroscopeModel>()).first
        #expect(chart?.name == "Larry Grayson")
        #expect(chart?.placeName == "Enschede,Netherlands")
        #expect(chart?.roddenRating == "AA")
    }

    @Test("AdbXmlImportOrchestrator: malformed XML produces zero imported charts and a fatal message")
    func testMalformedXmlImportsNothing() throws {
        let context = try makeContext()
        let result = AdbXmlImportOrchestrator(context: context).importFile(data: Data("<not valid".utf8))
        #expect(result.chartsImported == 0)
        #expect(!result.fatalMessages.isEmpty)
    }

    @Test("AdbXmlImportOrchestrator: a fatal entry does not block the rest of the file")
    func testFatalEntryDoesNotAbortFile() throws {
        let content = """
        <?xml version="1.0"?>
        <astrodatabank_export export_format="160715">
          <adb_entry adb_id="1">
            <public_data>
              <name>Broken, One</name>
            </public_data>
          </adb_entry>
          <adb_entry adb_id="2">
            <public_data>
              <name>Doe, Jane</name>
              <sbdate ccalendar="g" iyear="2000" imonth="1" iday="1">2000/1/1</sbdate>
              <sbtime ctimetype="s" stmerid="h0e">12:00:00</sbtime>
              <place slati="0n00" slong="0e00">City</place>
            </public_data>
          </adb_entry>
        </astrodatabank_export>
        """
        let context = try makeContext()
        let result = AdbXmlImportOrchestrator(context: context).importFile(data: Data(content.utf8))
        #expect(result.chartsImported == 1)
        #expect(result.fatalMessages.count == 1)
    }
}
