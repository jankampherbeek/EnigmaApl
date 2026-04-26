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
///
/// Output order: data section first, control-group section second.
/// When `divisor` > 1, control-group counts are divided by `divisor` and
/// formatted to one decimal place (matching the "Proportional" view in the UI).
struct ResultsExporter {

    init() {}

    /// Exports `result` to a CSV file at `destinationPath`.
    /// - Parameters:
    ///   - result: The analysis result to export.
    ///   - destinationPath: Full path of the output file.
    ///   - divisor: 1 for raw control counts; `cgMultiplication` for proportional counts.
    func export(_ result: AnalysisResult, to destinationPath: String, divisor: Int = 1) throws {
        let csv: String
        switch result {
        case .factorsInSigns(let r):    csv = buildFactorsInSignsCsv(r, divisor: divisor)
        case .factorsInHouses(let r):   csv = buildFactorsInHousesCsv(r, divisor: divisor)
        case .aspects(let r):           csv = buildAspectsCsv(r, divisor: divisor)
        case .unaspect(let r):          csv = buildUnaspectCsv(r, divisor: divisor)
        case .midpoints(let r):         csv = buildMidpointsCsv(r, divisor: divisor)
        case .harmonics(let r):         csv = buildHarmonicsCsv(r, divisor: divisor)
        case .parallels(let r):         csv = buildParallelsCsv(r, divisor: divisor)
        case .declMidpoints(let r):     csv = buildDeclMidpointsCsv(r, divisor: divisor)
        case .oob(let r):               csv = buildOobCsv(r, divisor: divisor)
        }
        do {
            try csv.write(toFile: destinationPath, atomically: true, encoding: .utf8)
        } catch {
            throw ResultsExporterError.writeFailed(destinationPath)
        }
    }

    // MARK: - Helpers

    /// Formats a control-group integer count.
    /// When divisor > 1, divides and shows one decimal place; otherwise plain integer.
    private func ctrl(_ count: Int, divisor: Int) -> String {
        divisor > 1 ? String(format: "%.1f", Double(count) / Double(divisor)) : "\(count)"
    }

    // MARK: - Factors in Signs

    /// Layout:
    /// ```
    /// Data
    /// Factor;<sign1>;…;<sign12>;Total
    /// <factorName>;<dataCount1>;…;<dataCount12>;<totalData>
    /// …
    ///
    /// Control group
    /// Factor;<sign1>;…;<sign12>;Total
    /// <factorName>;<ctrlCount1>;…;<ctrlCount12>;<ctrlTotal>
    /// …
    /// ```
    private func buildFactorsInSignsCsv(_ result: FactorsInSignsResult, divisor: Int) -> String {
        var lines: [String] = []
        let signHeaders = Signs.allCases.map { "\($0)" }.joined(separator: ";")
        let colHeader   = "Factor;\(signHeaders);Total"

        lines.append("Data")
        lines.append(colHeader)
        for dist in result.distributions {
            let dataCounts = dist.signCounts.map { String($0.dataCount) }.joined(separator: ";")
            lines.append("\(dist.factor);\(dataCounts);\(dist.totalData)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for dist in result.distributions {
            let ctrlCounts = dist.signCounts.map { ctrl($0.controlCount, divisor: divisor) }.joined(separator: ";")
            lines.append("\(dist.factor);\(ctrlCounts);\(ctrl(dist.totalControl, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Factors in Houses

    /// Layout:
    /// ```
    /// Data
    /// Factor;House 1;…;House 12;Total
    /// …
    ///
    /// Control group
    /// Factor;House 1;…;House 12;Total
    /// …
    /// ```
    private func buildFactorsInHousesCsv(_ result: FactorsInHousesResult, divisor: Int) -> String {
        var lines: [String] = []
        let houseHeaders = (1...result.nrOfHouses).map { "House \($0)" }.joined(separator: ";")
        let colHeader    = "Factor;\(houseHeaders);Total"

        lines.append("Data")
        lines.append(colHeader)
        for dist in result.distributions {
            let dataCounts   = dist.houseCounts.map { String($0.dataCount) }.joined(separator: ";")
            let totalData    = dist.houseCounts.reduce(0) { $0 + $1.dataCount }
            lines.append("\(dist.factor);\(dataCounts);\(totalData)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for dist in result.distributions {
            let ctrlCounts   = dist.houseCounts.map { ctrl($0.controlCount, divisor: divisor) }.joined(separator: ";")
            let totalControl = dist.houseCounts.reduce(0) { $0 + $1.controlCount }
            lines.append("\(dist.factor);\(ctrlCounts);\(ctrl(totalControl, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Aspects

    /// Layout:
    /// ```
    /// Data
    /// Factor 1;Factor 2;Aspect angle;Count
    /// …
    ///
    /// Control group
    /// Factor 1;Factor 2;Aspect angle;Count
    /// …
    /// ```
    private func buildAspectsCsv(_ result: AspectsResult, divisor: Int) -> String {
        var lines: [String] = []
        let colHeader = "Factor 1;Factor 2;Aspect angle;Count"

        lines.append("Data")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factor1);\(c.factor2);\(c.aspectAngle);\(c.dataCount)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factor1);\(c.factor2);\(c.aspectAngle);\(ctrl(c.controlCount, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Unaspect

    /// Layout:
    /// ```
    /// Data
    /// Factor;Count
    /// …
    ///
    /// Control group
    /// Factor;Count
    /// …
    /// ```
    private func buildUnaspectCsv(_ result: UnaspectResult, divisor: Int) -> String {
        var lines: [String] = []
        let colHeader = "Factor;Count"

        lines.append("Data")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factor);\(c.dataCount)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factor);\(ctrl(c.controlCount, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Midpoints

    /// Layout:
    /// ```
    /// Data
    /// Factor A;Factor B;Occupant;Dial size;Count
    /// …
    ///
    /// Control group
    /// Factor A;Factor B;Occupant;Dial size;Count
    /// …
    /// ```
    private func buildMidpointsCsv(_ result: MidpointsResult, divisor: Int) -> String {
        var lines: [String] = []
        let colHeader = "Factor A;Factor B;Occupant;Dial size;Count"

        lines.append("Data")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factorA);\(c.factorB);\(c.occupant);\(c.dialSize);\(c.dataCount)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factorA);\(c.factorB);\(c.occupant);\(c.dialSize);\(ctrl(c.controlCount, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Harmonics

    /// Layout:
    /// ```
    /// Harmonic number;<n>
    ///
    /// Data
    /// Harmonic factor;Radix factor;Count
    /// …
    ///
    /// Control group
    /// Harmonic factor;Radix factor;Count
    /// …
    /// ```
    private func buildHarmonicsCsv(_ result: HarmonicsResult, divisor: Int) -> String {
        var lines: [String] = []
        lines.append("Harmonic number;\(result.harmonicNumber)")
        lines.append("")
        let colHeader = "Harmonic factor;Radix factor;Count"

        lines.append("Data")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.harmonicFactor);\(c.radixFactor);\(c.dataCount)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.harmonicFactor);\(c.radixFactor);\(ctrl(c.controlCount, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Parallels

    /// Layout:
    /// ```
    /// Data
    /// Factor 1;Factor 2;Type;Count
    /// …
    ///
    /// Control group
    /// Factor 1;Factor 2;Type;Count
    /// …
    /// ```
    private func buildParallelsCsv(_ result: ParallelsResult, divisor: Int) -> String {
        var lines: [String] = []
        let colHeader = "Factor 1;Factor 2;Type;Count"

        lines.append("Data")
        lines.append(colHeader)
        for c in result.counts {
            let typeStr = c.isContraParallel ? "Contra-parallel" : "Parallel"
            lines.append("\(c.factor1);\(c.factor2);\(typeStr);\(c.dataCount)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for c in result.counts {
            let typeStr = c.isContraParallel ? "Contra-parallel" : "Parallel"
            lines.append("\(c.factor1);\(c.factor2);\(typeStr);\(ctrl(c.controlCount, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Declination Midpoints

    /// Layout:
    /// ```
    /// Data
    /// Factor A;Factor B;Occupant;Count
    /// …
    ///
    /// Control group
    /// Factor A;Factor B;Occupant;Count
    /// …
    /// ```
    private func buildDeclMidpointsCsv(_ result: DeclMidpointsResult, divisor: Int) -> String {
        var lines: [String] = []
        let colHeader = "Factor A;Factor B;Occupant;Count"

        lines.append("Data")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factorA);\(c.factorB);\(c.occupant);\(c.dataCount)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factorA);\(c.factorB);\(c.occupant);\(ctrl(c.controlCount, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Out of Bounds

    /// Layout:
    /// ```
    /// Obliquity threshold;<obliquity>
    ///
    /// Data
    /// Factor;Count
    /// …
    ///
    /// Control group
    /// Factor;Count
    /// …
    /// ```
    private func buildOobCsv(_ result: OobResult, divisor: Int) -> String {
        var lines: [String] = []
        lines.append("Obliquity threshold;\(result.obliquity)")
        lines.append("")
        let colHeader = "Factor;Count"

        lines.append("Data")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factor);\(c.dataCount)")
        }
        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for c in result.counts {
            lines.append("\(c.factor);\(ctrl(c.controlCount, divisor: divisor))")
        }

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }
}
