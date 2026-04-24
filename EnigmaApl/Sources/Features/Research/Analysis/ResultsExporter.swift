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
        }
        do {
            try csv.write(toFile: destinationPath, atomically: true, encoding: .utf8)
        } catch {
            throw ResultsExporterError.writeFailed(destinationPath)
        }
    }

    // MARK: - Factors in Signs

    /// Produces one section per factor.
    ///
    /// Layout:
    /// ```
    /// Factor;<sign1>;…;<sign12>;Total data;Total control
    /// <factorName>;<dataCount1>;…;<dataCount12>;<totalData>;<totalControl>
    /// <factorName> (control);<ctrlCount1>;…;<ctrlCount12>;<totalData>;<totalControl>
    /// (blank line between factors)
    /// ```
    private func buildFactorsInSignsCsv(_ result: FactorsInSignsResult) -> String {
        var lines: [String] = []

        // Header row
        let signHeaders = Signs.allCases.map { "\($0)" }.joined(separator: ";")
        lines.append("Factor;\(signHeaders);Total data;Total control")

        for dist in result.distributions {
            let factorName = "\(dist.factor)"

            let dataCounts    = dist.signCounts.map { String($0.dataCount)    }.joined(separator: ";")
            let controlCounts = dist.signCounts.map { String($0.controlCount) }.joined(separator: ";")

            lines.append("\(factorName);\(dataCounts);\(dist.totalData);\(dist.totalControl)")
            lines.append("\(factorName) (control);\(controlCounts);\(dist.totalData);\(dist.totalControl)")
            lines.append("")  // blank separator between factors
        }

        if result.skippedRecords > 0 {
            lines.append("# Skipped records: \(result.skippedRecords)")
        }

        return lines.joined(separator: "\n")
    }
}
