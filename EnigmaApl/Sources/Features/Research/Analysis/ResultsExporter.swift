// ResultsExporter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Errors thrown by ResultsExporter.
enum ResultsExporterError: Error {
    case writeFailed(String)
    case unsupportedResult
}

/// Exports analysis results to a semicolon-delimited CSV file.
///
/// Each `AnalysisResult` case produces its own column layout.
/// The file is written to `destinationPath` and overwrites any existing file.
struct ResultsExporter {

    init() {}

    /// Exports `result` to a CSV file at `destinationPath`.
    /// - Parameters:
    ///   - result: The analysis result to export.
    ///   - destinationPath: Full path of the output file (e.g. `.../exports/factors_in_signs.csv`).
    func export(_ result: AnalysisResult, to destinationPath: String) throws {
        let csv: String
        switch result {
        case .factorsInSigns(let r):
            csv = buildFactorsInSignsCsv(r)
        case .factorsInHouses(let r):
            csv = buildFactorsInHousesCsv(r)
        case .aspects(let r):
            csv = buildAspectsCsv(r)
        case .unaspect(let r):
            csv = buildUnaspectCsv(r)
        case .midpoints(let r):
            csv = buildMidpointsCsv(r)
        case .harmonics(let r):
            csv = buildHarmonicsCsv(r)
        case .parallels(let r):
            csv = buildParallelsCsv(r)
        case .declMidpoints(let r):
            csv = buildDeclMidpointsCsv(r)
        case .oob(let r):
            csv = buildOobCsv(r)
        }
        do {
            try csv.write(toFile: destinationPath, atomically: true, encoding: .utf8)
        } catch {
            throw ResultsExporterError.writeFailed(destinationPath)
        }
    }

    // MARK: - Factors in Signs

    /// Layout:
    /// ```
    /// Factor;<sign1>;…;<sign12>;Total data;Total control
    /// <factorName>;<dataCount1>;…;<dataCount12>;<totalData>;<totalControl>
    /// <factorName> (control);<ctrlCount1>;…;<ctrlCount12>;<totalData>;<totalControl>
    /// (blank line between factors)
    /// ```
    private func buildFactorsInSignsCsv(_ result: FactorsInSignsResult) -> String {
        var lines: [String] = []

        let signHeaders = Signs.allCases.map { "\($0)" }.joined(separator: ";")
        lines.append("Factor;\(signHeaders);Total data;Total control")

        for dist in result.distributions {
            let factorName = "\(dist.factor)"
            let dataCounts    = dist.signCounts.map { String($0.dataCount)    }.joined(separator: ";")
            let controlCounts = dist.signCounts.map { String($0.controlCount) }.joined(separator: ";")
            lines.append("\(factorName);\(dataCounts);\(dist.totalData);\(dist.totalControl)")
            lines.append("\(factorName) (control);\(controlCounts);\(dist.totalData);\(dist.totalControl)")
            lines.append("")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Factors in Houses

    /// Layout:
    /// ```
    /// Factor;House 1;…;House 12;Total data;Total control
    /// <factorName>;<dataCount1>;…;<dataCount12>;<totalData>;<totalControl>
    /// <factorName> (control);<ctrlCount1>;…;<ctrlCount12>;<totalData>;<totalControl>
    /// (blank line between factors)
    /// ```
    private func buildFactorsInHousesCsv(_ result: FactorsInHousesResult) -> String {
        var lines: [String] = []

        let houseHeaders = (1...12).map { "House \($0)" }.joined(separator: ";")
        lines.append("Factor;\(houseHeaders);Total data;Total control")

        for dist in result.distributions {
            let factorName = "\(dist.factor)"
            let dataCounts    = dist.houseCounts.map { String($0.dataCount)    }.joined(separator: ";")
            let controlCounts = dist.houseCounts.map { String($0.controlCount) }.joined(separator: ";")
            let totalData    = dist.houseCounts.reduce(0) { $0 + $1.dataCount }
            let totalControl = dist.houseCounts.reduce(0) { $0 + $1.controlCount }
            lines.append("\(factorName);\(dataCounts);\(totalData);\(totalControl)")
            lines.append("\(factorName) (control);\(controlCounts);\(totalData);\(totalControl)")
            lines.append("")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Aspects

    /// Layout:
    /// ```
    /// Factor 1;Factor 2;Aspect angle;Data count;Control count
    /// <f1>;<f2>;<angle>;<data>;<ctrl>
    /// …
    /// ```
    private func buildAspectsCsv(_ result: AspectsResult) -> String {
        var lines: [String] = []
        lines.append("Factor 1;Factor 2;Aspect angle;Data count;Control count")

        for count in result.counts {
            lines.append("\(count.factor1);\(count.factor2);\(count.aspectAngle);\(count.dataCount);\(count.controlCount)")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Unaspect

    /// Layout:
    /// ```
    /// Factor;Data count;Control count
    /// <factor>;<data>;<ctrl>
    /// …
    /// ```
    private func buildUnaspectCsv(_ result: UnaspectResult) -> String {
        var lines: [String] = []
        lines.append("Factor;Data count;Control count")

        for count in result.counts {
            lines.append("\(count.factor);\(count.dataCount);\(count.controlCount)")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Midpoints

    /// Layout:
    /// ```
    /// Factor A;Factor B;Occupant;Dial size;Data count;Control count
    /// …
    /// ```
    private func buildMidpointsCsv(_ result: MidpointsResult) -> String {
        var lines: [String] = []
        lines.append("Factor A;Factor B;Occupant;Dial size;Data count;Control count")

        for count in result.counts {
            lines.append("\(count.factorA);\(count.factorB);\(count.occupant);\(count.dialSize);\(count.dataCount);\(count.controlCount)")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Harmonics

    /// Layout:
    /// ```
    /// Harmonic number;<harmonicNumber>
    /// Harmonic factor;Radix factor;Data count;Control count
    /// …
    /// ```
    private func buildHarmonicsCsv(_ result: HarmonicsResult) -> String {
        var lines: [String] = []
        lines.append("Harmonic number;\(result.harmonicNumber)")
        lines.append("Harmonic factor;Radix factor;Data count;Control count")

        for count in result.counts {
            lines.append("\(count.harmonicFactor);\(count.radixFactor);\(count.dataCount);\(count.controlCount)")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Parallels

    /// Layout:
    /// ```
    /// Factor 1;Factor 2;Type;Data count;Control count
    /// <f1>;<f2>;Parallel;<data>;<ctrl>
    /// <f1>;<f2>;Contra-parallel;<data>;<ctrl>
    /// …
    /// ```
    private func buildParallelsCsv(_ result: ParallelsResult) -> String {
        var lines: [String] = []
        lines.append("Factor 1;Factor 2;Type;Data count;Control count")

        for count in result.counts {
            let typeStr = count.isContraParallel ? "Contra-parallel" : "Parallel"
            lines.append("\(count.factor1);\(count.factor2);\(typeStr);\(count.dataCount);\(count.controlCount)")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Declination Midpoints

    /// Layout:
    /// ```
    /// Factor A;Factor B;Occupant;Data count;Control count
    /// …
    /// ```
    private func buildDeclMidpointsCsv(_ result: DeclMidpointsResult) -> String {
        var lines: [String] = []
        lines.append("Factor A;Factor B;Occupant;Data count;Control count")

        for count in result.counts {
            lines.append("\(count.factorA);\(count.factorB);\(count.occupant);\(count.dataCount);\(count.controlCount)")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Out of Bounds

    /// Layout:
    /// ```
    /// Obliquity threshold;<obliquity>
    /// Factor;Data count;Control count
    /// …
    /// ```
    private func buildOobCsv(_ result: OobResult) -> String {
        var lines: [String] = []
        lines.append("Obliquity threshold;\(result.obliquity)")
        lines.append("Factor;Data count;Control count")

        for count in result.counts {
            lines.append("\(count.factor);\(count.dataCount);\(count.controlCount)")
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }
}
