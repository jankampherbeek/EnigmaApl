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
        divisor > 1 ? (Double(count) / Double(divisor)).formatted(.number.precision(.fractionLength(1))) : "\(count)"
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

        // Per-sign totals across all factors
        let dataSignTotals: [Int] = (0..<12).map { si in
            result.distributions.reduce(0) { $0 + $1.signCounts[si].dataCount }
        }
        let ctrlSignTotals: [Int] = (0..<12).map { si in
            result.distributions.reduce(0) { $0 + $1.signCounts[si].controlCount }
        }
        let dataGrandTotal = dataSignTotals.reduce(0, +)
        let ctrlGrandTotal = ctrlSignTotals.reduce(0, +)

        lines.append("Data")
        lines.append(colHeader)
        for dist in result.distributions {
            let dataCounts = dist.signCounts.map { String($0.dataCount) }.joined(separator: ";")
            lines.append("\(dist.factor);\(dataCounts);\(dist.totalData)")
        }
        let dataTotalRow = dataSignTotals.map { String($0) }.joined(separator: ";")
        lines.append("Total;\(dataTotalRow);\(dataGrandTotal)")

        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for dist in result.distributions {
            let ctrlCounts = dist.signCounts.map { ctrl($0.controlCount, divisor: divisor) }.joined(separator: ";")
            lines.append("\(dist.factor);\(ctrlCounts);\(ctrl(dist.totalControl, divisor: divisor))")
        }
        let ctrlTotalRow = ctrlSignTotals.map { ctrl($0, divisor: divisor) }.joined(separator: ";")
        lines.append("Total;\(ctrlTotalRow);\(ctrl(ctrlGrandTotal, divisor: divisor))")

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

        // Per-house totals across all factors
        let dataHouseTotals: [Int] = (0..<result.nrOfHouses).map { hi in
            result.distributions.reduce(0) { $0 + $1.houseCounts[hi].dataCount }
        }
        let ctrlHouseTotals: [Int] = (0..<result.nrOfHouses).map { hi in
            result.distributions.reduce(0) { $0 + $1.houseCounts[hi].controlCount }
        }
        let dataGrandTotal = dataHouseTotals.reduce(0, +)
        let ctrlGrandTotal = ctrlHouseTotals.reduce(0, +)

        lines.append("Data")
        lines.append(colHeader)
        for dist in result.distributions {
            let dataCounts = dist.houseCounts.map { String($0.dataCount) }.joined(separator: ";")
            lines.append("\(dist.factor);\(dataCounts);\(dist.totalData)")
        }
        let dataTotalRow = dataHouseTotals.map { String($0) }.joined(separator: ";")
        lines.append("Total;\(dataTotalRow);\(dataGrandTotal)")

        lines.append("")
        lines.append("Control group")
        lines.append(colHeader)
        for dist in result.distributions {
            let ctrlCounts = dist.houseCounts.map { ctrl($0.controlCount, divisor: divisor) }.joined(separator: ";")
            lines.append("\(dist.factor);\(ctrlCounts);\(ctrl(dist.totalControl, divisor: divisor))")
        }
        let ctrlTotalRow = ctrlHouseTotals.map { ctrl($0, divisor: divisor) }.joined(separator: ";")
        lines.append("Total;\(ctrlTotalRow);\(ctrl(ctrlGrandTotal, divisor: divisor))")

        if result.skippedRecords > 0 {
            lines.append("")
            lines.append("# Skipped records: \(result.skippedRecords)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Aspects

    /// Matrix layout:
    /// ```
    /// Data
    /// Factor 1;Factor 2;<angle1>°;<angle2>°;…;Total
    /// <f1>;<f2>;<count>;…;<rowTotal>
    /// …
    /// Total;;<colTotal>;…;<grandTotal>
    ///
    /// Control group
    /// …
    /// ```
    private func buildAspectsCsv(_ result: AspectsResult, divisor: Int) -> String {
        var lines: [String] = []

        let angles: [Double] = Array(Set(result.counts.map(\.aspectAngle))).sorted()

        var seenPairs = Set<String>()
        var factorPairs: [(Factors, Factors)] = []
        for c in result.counts {
            let key = "\(c.factor1.rawValue)-\(c.factor2.rawValue)"
            if seenPairs.insert(key).inserted { factorPairs.append((c.factor1, c.factor2)) }
        }

        func lookup(_ f1: Factors, _ f2: Factors, _ angle: Double, isData: Bool) -> Int {
            result.counts.first { $0.factor1 == f1 && $0.factor2 == f2 && $0.aspectAngle == angle }
                .map { isData ? $0.dataCount : $0.controlCount } ?? 0
        }

        let angleHeaders = angles.map { "\($0.formatted(.number.precision(.significantDigits(1...5))))°" }.joined(separator: ";")
        let colHeader = "Factor 1;Factor 2;\(angleHeaders);Total"

        for (sectionLabel, isData) in [("Data", true), ("Control group", false)] {
            let angleTotals: [Int] = angles.map { angle in
                result.counts.filter { $0.aspectAngle == angle }
                    .reduce(0) { $0 + (isData ? $1.dataCount : $1.controlCount) }
            }
            let grandTotal = angleTotals.reduce(0, +)

            lines.append(sectionLabel)
            lines.append(colHeader)
            for pair in factorPairs {
                let row = angles.map { lookup(pair.0, pair.1, $0, isData: isData) }
                let rowTotal = row.reduce(0, +)
                let cells = row.map { isData ? "\($0)" : ctrl($0, divisor: divisor) }.joined(separator: ";")
                let rowTotalStr = isData ? "\(rowTotal)" : ctrl(rowTotal, divisor: divisor)
                lines.append("\(pair.0);\(pair.1);\(cells);\(rowTotalStr)")
            }
            let totCells = angleTotals.map { isData ? "\($0)" : ctrl($0, divisor: divisor) }.joined(separator: ";")
            let grandTotalStr = isData ? "\(grandTotal)" : ctrl(grandTotal, divisor: divisor)
            lines.append("Total;;\(totCells);\(grandTotalStr)")
            lines.append("")
        }

        if result.skippedRecords > 0 {
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
        let colHeader = "Factor 1;Factor 2;Parallel;Contra-parallel;Total"

        // Unique factor pairs in sorted order
        var seen = Set<String>()
        var pairs: [(Factors, Factors)] = []
        for c in result.counts {
            let key = "\(c.factor1.rawValue)-\(c.factor2.rawValue)"
            if seen.insert(key).inserted { pairs.append((c.factor1, c.factor2)) }
        }
        pairs.sort {
            if $0.0.rawValue != $1.0.rawValue { return $0.0.rawValue < $1.0.rawValue }
            return $0.1.rawValue < $1.1.rawValue
        }

        func parallelCount(_ f1: Factors, _ f2: Factors, isContra: Bool) -> (data: Int, control: Int) {
            let match = result.counts.first { $0.factor1 == f1 && $0.factor2 == f2 && $0.isContraParallel == isContra }
            return (match?.dataCount ?? 0, match?.controlCount ?? 0)
        }

        for section in ["Data", "Control group"] {
            let isData = (section == "Data")
            lines.append(section)
            lines.append(colHeader)
            var totalP = 0, totalC = 0
            for (f1, f2) in pairs {
                let p = parallelCount(f1, f2, isContra: false)
                let c = parallelCount(f1, f2, isContra: true)
                let pRaw = isData ? p.data    : p.control
                let cRaw = isData ? c.data    : c.control
                let pOut = isData ? "\(pRaw)" : ctrl(pRaw, divisor: divisor)
                let cOut = isData ? "\(cRaw)" : ctrl(cRaw, divisor: divisor)
                let sOut = isData ? "\(pRaw + cRaw)" : ctrl(pRaw + cRaw, divisor: divisor)
                lines.append("\(f1);\(f2);\(pOut);\(cOut);\(sOut)")
                totalP += pRaw; totalC += cRaw
            }
            let pOut = isData ? "\(totalP)" : ctrl(totalP, divisor: divisor)
            let cOut = isData ? "\(totalC)" : ctrl(totalC, divisor: divisor)
            let sOut = isData ? "\(totalP + totalC)" : ctrl(totalP + totalC, divisor: divisor)
            lines.append("Total;\(pOut);\(cOut);\(sOut)")
            lines.append("")
        }

        if result.skippedRecords > 0 {
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
        lines.append("Obliquity threshold;\(result.obliquity.formatted(.number.precision(.fractionLength(4))))")
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
