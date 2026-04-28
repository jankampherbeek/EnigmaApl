// AnalysisOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Errors thrown by AnalysisOrchestrator.
enum AnalysisOrchestratorError: Error {
    case missingResultsFile(String)
    case configDecodingFailed
    case inquiryNotSupported(Inquiries)
    case workerFailed(Error)
    case missingInputDatabase(String)
    case missingCalculationConfig
}

/// Typed union of all possible analysis results.
enum AnalysisResult: Sendable {
    case factorsInSigns(FactorsInSignsResult)
    case factorsInHouses(FactorsInHousesResult)
    case aspects(AspectsResult)
    case unaspect(UnaspectResult)
    case midpoints(MidpointsResult)
    case harmonics(HarmonicsResult)
    case parallels(ParallelsResult)
    case declMidpoints(DeclMidpointsResult)
    case oob(OobResult)
}

/// Dispatches analysis for a project to the correct worker based on the project's `inquiryType`.
/// Opens `results.bin` (memory-mapped), runs the worker synchronously, and returns the result.
///
/// Call from a background `Task` — the work is synchronous and potentially large.
struct AnalysisOrchestrator {

    init() {}

    /// Sendable-safe entry point — accepts plain strings instead of the SwiftData model.
    /// Use this when calling from `Task.detached` or across actor boundaries.
    func runWith(path: String, configJson: String, inquiryId: Int) throws -> AnalysisResult {
        guard let config = try? ResearchConfig.from(json: configJson) else {
            throw AnalysisOrchestratorError.configDecodingFailed
        }
        let binaryFile: ResultsBinaryFile
        do {
            binaryFile = try ResultsBinaryFile.open(at: path)
        } catch {
            throw AnalysisOrchestratorError.missingResultsFile(path)
        }
        try binaryFile.memoryMap()

        guard let inquiry = Inquiries(rawValue: inquiryId) else {
            throw AnalysisOrchestratorError.inquiryNotSupported(.factorsInSigns)
        }
        return try dispatch(inquiry: inquiry, config: config, binaryFile: binaryFile,
                            projectPath: path, projectConfig: configJson)
    }

    func run(project: ResearchProjectModel) throws -> AnalysisResult {
        try runWith(path: project.path, configJson: project.config,
                    inquiryId: project.enquiry)
    }

    // MARK: - Shared dispatch

    private func dispatch(inquiry: Inquiries, config: ResearchConfig,
                          binaryFile: ResultsBinaryFile,
                          projectPath: String, projectConfig: String) throws -> AnalysisResult {
        do {
            switch inquiry {

            case .factorsInSigns:
                let worker = FactorsInSignsWorker(binaryFile: binaryFile, config: config)
                return .factorsInSigns(try worker.run())

            case .factorsInHouses:
                let cusps = try cuspLongitudes(atPath: projectPath, config: config)
                let worker = FactorsInHousesWorker(binaryFile: binaryFile, config: config,
                                                   cuspLongitudesByRecord: cusps)
                return .factorsInHouses(try worker.run())

            case .aspects:
                let (angles, orb) = aspectParameters(config: config)
                let worker = AspectsWorker(binaryFile: binaryFile, config: config,
                                          aspectAngles: angles, orb: orb)
                return .aspects(try worker.run())

            case .unaspect:
                let (angles, _) = aspectParameters(config: config)
                let unaspectOrb = config.unaspectOrbOverride
                    ?? config.orbConfig?.aspectBaseOrb
                    ?? 8.0
                let worker = UnaspectWorker(binaryFile: binaryFile, config: config,
                                           aspectAngles: angles, orb: unaspectOrb)
                return .unaspect(try worker.run())

            case .midpoints:
                let dialSizes = config.enabledDialSizes ?? [360]
                let orbsPerDialSize: [Int: Double] = [
                    360: config.orbConfig?.midpoint360DialOrb ?? 1.5,
                    90:  config.orbConfig?.midpoint90DialOrb  ?? 1.0,
                    45:  config.orbConfig?.midpoint45DialOrb  ?? 0.5
                ]
                let worker = MidpointsWorker(binaryFile: binaryFile, config: config,
                                            dialSizes: dialSizes, orbsPerDialSize: orbsPerDialSize)
                return .midpoints(try worker.run())

            case .harmonics:
                let orb = config.orbConfig?.harmonicOrb ?? 1.0
                let harmonicNumber = config.harmonicNumber ?? 5
                let worker = HarmonicsWorker(binaryFile: binaryFile, config: config,
                                            harmonicNumber: harmonicNumber, orb: orb)
                return .harmonics(try worker.run())

            case .parallels:
                let orb = config.orbConfig?.parallelOrb ?? 1.0
                let worker = ParallelsWorker(binaryFile: binaryFile, config: config, orb: orb)
                return .parallels(try worker.run())

            case .declMidpoints:
                let orb = config.declMidpointOrbOverride ?? config.orbConfig?.declinationMidpointOrb ?? 1.0
                let worker = DeclMidpointsWorker(binaryFile: binaryFile, config: config, orb: orb)
                return .declMidpoints(try worker.run())

            case .oob:
                let obliquities = try obliquitiesPerRecord(atPath: projectPath)
                let worker = OobWorker(binaryFile: binaryFile, config: config,
                                       obliquityPerRecord: obliquities)
                return .oob(try worker.run())
            }
        } catch {
            throw AnalysisOrchestratorError.workerFailed(error)
        }
    }

    // MARK: - Helpers

    /// Resolves aspect angles and orb from the stored config.
    private func aspectParameters(config: ResearchConfig) -> (angles: [Double], orb: Double) {
        let orb = config.aspectOrbOverride
            ?? config.orbConfig?.aspectBaseOrb
            ?? 8.0
        let allAngles: [Double] = [0, 30, 45, 60, 72, 90, 120, 135, 144, 150, 180]
        let angles: [Double]
        if let ids = config.enabledAspectIds {
            // Map Aspects rawValue → its angle. Keep only those in the enabled list.
            angles = ids.compactMap { id -> Double? in
                guard let aspect = Aspects(rawValue: id) else { return nil }
                return aspect.angle
            }
        } else {
            angles = allAngles
        }
        return (angles, orb)
    }

    /// Re-calculates house cusp longitudes for every record in the project database.
    /// Returns an array indexed by record position (same order as `ResearchDbManager.fetchAll()`).
    private func cuspLongitudes(atPath path: String,
                                config: ResearchConfig) throws -> [[Double]] {
        guard let calcConfig = config.calculationConfig else {
            throw AnalysisOrchestratorError.missingCalculationConfig
        }
        let db: ResearchDbManager
        do {
            db = try ResearchDbManager(folderPath: path)
        } catch {
            throw AnalysisOrchestratorError.missingInputDatabase(path)
        }
        let records = try db.fetchAll()
        let seWrapper = SEWrapper()

        return records.map { record in
            let utHour = utDecimalHour(hour: record.hour, minute: record.minute,
                                       second: record.second, offset: record.offset)
            let date = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day)
            let time = AstronomicalTime(HourDecimal: utHour)
            let julDay = seWrapper.julianDay(date: date, time: time)
            let request = CalcRequest(
                JulianDay: julDay,
                FactorsToUse: [],
                HouseSystem: calcConfig.houseSystem.rawValue,
                Latitude: record.geoLat,
                Longitude: record.geoLon,
                Height: 0,
                calculationConfig: calcConfig
            )
            let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
            return chart.HousePositions.cusps.map { $0.longitude }
        }
    }

    /// Calculates the true obliquity of the ecliptic for every record in the project database.
    /// Uses Swiss Ephemeris factor id -1 with flags 2 (SE, no speed), which returns the
    /// true obliquity in `mainPos`.  Returns values in binary-file order (same as `fetchAll()`).
    private func obliquitiesPerRecord(atPath path: String) throws -> [Double] {
        let db: ResearchDbManager
        do {
            db = try ResearchDbManager(folderPath: path)
        } catch {
            throw AnalysisOrchestratorError.missingInputDatabase(path)
        }
        let records = try db.fetchAll()
        let seWrapper = SEWrapper()

        return records.map { record in
            let utHour = utDecimalHour(hour: record.hour, minute: record.minute,
                                       second: record.second, offset: record.offset)
            let date = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day)
            let time = AstronomicalTime(HourDecimal: utHour)
            let julDay = seWrapper.julianDay(date: date, time: time)
            return seWrapper.calculateFactorPosition(julianDay: julDay, factor: -1, flags: 2)?.mainPos
                ?? 23.4393
        }
    }

    private func utDecimalHour(hour: Int, minute: Int, second: Int, offset: Double) -> Double {
        Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0 - offset
    }
}
