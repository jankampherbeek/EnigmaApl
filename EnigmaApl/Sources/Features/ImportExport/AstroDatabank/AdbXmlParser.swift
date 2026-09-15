// AdbXmlParser.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Parses Astro-Databank XML (`export_format="160715"`) into `[AdbXmlRecord]`
/// using Foundation's native `XMLParser`. No astrological calculation
/// happens here. Security: external entities are explicitly disabled and no
/// DTD is ever resolved, so parsing never depends on network access.
enum AdbXmlParser {

    static func parse(data: Data) -> FormatParseResult<AdbXmlRecord> {
        let delegate = Delegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldResolveExternalEntities = false
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false

        let success = parser.parse()
        var result = delegate.result

        if !success {
            let description = parser.parserError?.localizedDescription ?? "unknown error"
            result.messages.append(.fatal("Malformed XML at line \(parser.lineNumber), column \(parser.columnNumber): \(description)"))
        } else if !delegate.sawRoot {
            result.messages.append(.fatal("Root element 'astrodatabank_export' was not found."))
        } else if let declaredCount = delegate.declaredCount, declaredCount != result.records.count {
            result.messages.append(.warning("'adb_entry_count' declared \(declaredCount) entries, but \(result.records.count) were parsed."))
        }

        if !delegate.unknownElementNames.isEmpty {
            let names = delegate.unknownElementNames.sorted().joined(separator: ", ")
            result.messages.append(.warning("Unrecognized XML elements were ignored: \(names)."))
        }

        return result
    }

    // MARK: - SAX delegate

    private final class Delegate: NSObject, XMLParserDelegate {
        var result = FormatParseResult<AdbXmlRecord>()
        var sawRoot = false
        var declaredCount: Int?
        var unknownElementNames: Set<String> = []

        private var recordNumber = 0
        private var current: AdbXmlRecord?
        private var currentText = ""
        private var insideBdataAlt = false
        private var insideResearchData = false

        private let containerElements: Set<String> = [
            "astrodatabank_export", "timestamp", "adb_entry", "public_data",
            "text_data", "research_data", "bdata_alt", "adb_entry_count", "positions"
        ]
        private let knownLeafElements: Set<String> = [
            "name", "sflname", "birthname", "gender", "roddenrating", "datatype",
            "sbdate", "sbtime", "place", "country",
            "scollector", "seditor", "sbiographer", "screationdate", "slasteditdate",
            "sourcenotes", "wikipedia_link", "adb_link"
        ]

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
            currentText = ""

            switch elementName {
            case "astrodatabank_export":
                sawRoot = true
                let format = attributeDict["export_format"]
                if format != "160715" {
                    result.messages.append(.warning("Unrecognized export_format '\(format ?? "(missing)")'; attempting a tolerant import."))
                }
            case "adb_entry":
                recordNumber += 1
                current = AdbXmlRecord(adbId: attributeDict["adb_id"])
            case "adb_entry_count":
                declaredCount = attributeDict["count"].flatMap(Int.init)
            case "bdata_alt":
                insideBdataAlt = true
                current?.hasAlternativeBirthData = true
            case "research_data":
                insideResearchData = true
            case "sbdate":
                guard !insideBdataAlt, !insideResearchData else { break }
                current?.hasDate = true
                current?.isGregorian = (attributeDict["ccalendar"] ?? "g").lowercased() != "j"
                current?.year = Int(attributeDict["iyear"] ?? "") ?? 0
                current?.month = Int(attributeDict["imonth"] ?? "") ?? 0
                current?.day = Int(attributeDict["iday"] ?? "") ?? 0
            case "sbtime":
                guard !insideBdataAlt, !insideResearchData else { break }
                current?.timeTypeCode = attributeDict["ctimetype"]?.lowercased()
                current?.stmerid = attributeDict["stmerid"]
                current?.jdUt = attributeDict["jd_ut"].flatMap(Double.init)
            case "gender":
                guard !insideBdataAlt else { break }
                current?.genderCode = attributeDict["csex"]?.lowercased()
            case "place":
                guard !insideBdataAlt, !insideResearchData else { break }
                current?.latitude = attributeDict["slati"].flatMap { AdbXmlFieldParsers.parseCoordinate($0, positiveChar: "n", negativeChar: "s") }
                current?.longitude = attributeDict["slong"].flatMap { AdbXmlFieldParsers.parseCoordinate($0, positiveChar: "e", negativeChar: "w") }
            case "country":
                guard !insideBdataAlt else { break }
                current?.countryCode = attributeDict["sctr"]
            default:
                if !containerElements.contains(elementName) && !knownLeafElements.contains(elementName) {
                    unknownElementNames.insert(elementName)
                }
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            currentText += string
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
            defer { currentText = "" }

            switch elementName {
            case "adb_entry":
                if let builder = current {
                    let (record, messages) = finalize(builder, recordNumber: recordNumber)
                    result.messages.append(contentsOf: messages)
                    if let record { result.records.append(record) }
                }
                current = nil
            case "bdata_alt":
                insideBdataAlt = false
            case "research_data":
                insideResearchData = false
            case "name":
                guard !insideBdataAlt else { break }
                current?.name = text.isEmpty ? nil : text
            case "sflname":
                guard !insideBdataAlt else { break }
                current?.sflname = text.isEmpty ? nil : text
            case "birthname":
                guard !insideBdataAlt else { break }
                current?.birthname = text.isEmpty ? nil : text
            case "roddenrating":
                guard !insideBdataAlt else { break }
                current?.roddenRating = text.isEmpty ? nil : text
            case "sbtime":
                guard !insideBdataAlt, !insideResearchData else { break }
                if let parsed = AdbXmlFieldParsers.parseTime(text) {
                    current?.hasTime = true
                    current?.hour = parsed.hour
                    current?.minute = parsed.minute
                    current?.second = parsed.second
                }
            case "place":
                guard !insideBdataAlt, !insideResearchData else { break }
                current?.placeName = text.isEmpty ? nil : text
            case "country":
                guard !insideBdataAlt else { break }
                current?.countryName = text.isEmpty ? nil : text
            case "sourcenotes":
                guard !insideBdataAlt else { break }
                current?.sourceNotes = text.isEmpty ? nil : text
            default:
                break
            }
        }

        private func finalize(_ record: AdbXmlRecord, recordNumber: Int) -> (record: AdbXmlRecord?, messages: [ExchangeMessage]) {
            var messages: [ExchangeMessage] = []
            guard record.hasDate else {
                messages.append(.fatal("Entry has no birth date ('sbdate').", recordNumber: recordNumber))
                return (nil, messages)
            }
            let validation = AstronomicalDateValidation.validateDateComponents(year: record.year, month: record.month, day: record.day, gregorian: record.isGregorian)
            guard validation.isValid else {
                messages.append(.fatal(validation.message ?? "Invalid date.", recordNumber: recordNumber, field: "sbdate"))
                return (nil, messages)
            }
            if let latitude = record.latitude, let longitude = record.longitude {
                let (latDeg, _, _, _) = GeoCoordinateConversion.components(fromDecimalDegrees: latitude)
                let (lonDeg, _, _, _) = GeoCoordinateConversion.components(fromDecimalDegrees: longitude)
                guard latDeg <= 90, lonDeg <= 180 else {
                    messages.append(.fatal("Coordinates out of range for entry '\(record.adbId ?? "?")'.", recordNumber: recordNumber, field: "place"))
                    return (nil, messages)
                }
            }
            if record.hasAlternativeBirthData {
                messages.append(.warning("Alternative birth data ('bdata_alt') was present but is not imported; only the primary birth data was used.", recordNumber: recordNumber, field: "bdata_alt"))
            }
            return (record, messages)
        }
    }
}
