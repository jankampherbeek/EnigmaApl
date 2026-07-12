// LongTimeEphemerisResultsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
#if os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

private func lte(_ key: String) -> String {
    NSLocalizedString(key, tableName: "LongTimeEphemeris", bundle: .main, comment: "")
}

/// Short display name for a planet/factor, resolved via Localizable.strings.
private func factorName(_ factor: Factors) -> String {
    NSLocalizedString(factor.localizedName, bundle: .main, comment: "")
}

/// Two-letter abbreviation for each zodiac sign.
private func signAbbreviation(_ sign: Signs) -> String {
    switch sign {
    case .Aries:       return "AR"
    case .Taurus:      return "TA"
    case .Gemini:      return "GE"
    case .Cancer:      return "CN"
    case .Leo:         return "LE"
    case .Virgo:       return "VI"
    case .Libra:       return "LI"
    case .Scorpio:     return "SC"
    case .Sagittarius: return "SA"
    case .Capricorn:   return "CP"
    case .Aquarius:    return "AQ"
    case .Pisces:      return "PI"
    }
}

// MARK: - Root view

struct LongTimeEphemerisResultsView: View {
    @EnvironmentObject private var model: LongTimeEphemerisModel

    var body: some View {
        if model.rows.isEmpty || model.selectedFactors.isEmpty {
            if model.isCalculating {
                VStack(spacing: 12) {
                    ProgressView(value: model.progress)
                        .frame(maxWidth: 300)
                    Text(lte(LongTimeEphemerisKeys.calculating))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(lte(LongTimeEphemerisKeys.noResults))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            VStack(spacing: 0) {
                #if os(macOS)
                HStack {
                    Spacer()
                    Button {
                        triggerCsvExport()
                    } label: {
                        Label(lte(LongTimeEphemerisKeys.exportCsv), systemImage: "arrow.down.doc")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .background(.bar)
                Divider()
                #endif
                LteTableView()
            }
        }
    }

    #if os(macOS)
    private func triggerCsvExport() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.commaSeparatedText]
        panel.nameFieldStringValue = "LongTimeEphemeris.csv"
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            LteCsvExporter.export(
                to: url,
                rows: model.rows,
                factors: model.selectedFactors,
                coordinate: model.selectedCoordinate,
                displayFormat: model.displayFormat
            )
        }
    }
    #endif
}

// MARK: - Table dispatcher

private struct LteTableView: View {
    @EnvironmentObject private var model: LongTimeEphemerisModel

    var body: some View {
        #if os(macOS)
        LteNSTable(
            rows: model.rows,
            factors: model.selectedFactors,
            coordinate: model.selectedCoordinate,
            displayFormat: model.displayFormat
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        LteScrollTable()
        #endif
    }
}

// MARK: - macOS: NSTableView (proper row virtualization)
// NSTableView only requests cell views for visible rows, so 9 000+ row
// datasets never exhaust SwiftUI layout space.

#if os(macOS)
private struct LteNSTable: NSViewRepresentable {
    let rows: [LongTimeEphemerisRow]
    let factors: [Factors]
    let coordinate: EphemerisCoordinate
    let displayFormat: LongTimeEphemerisDisplayFormat

    private let dateColIDStr = "lte.date"
    private let dateColWidth: CGFloat = 164
    private let valueColWidth: CGFloat = 130

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = false
        scrollView.scrollerStyle = .legacy
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        let tv = NSTableView()
        tv.style = .plain
        tv.usesAlternatingRowBackgroundColors = true
        tv.gridStyleMask = [.solidVerticalGridLineMask]
        tv.rowHeight = 22
        tv.intercellSpacing = NSSize(width: 6, height: 2)
        tv.allowsColumnReordering = false
        tv.allowsColumnResizing = true
        tv.dataSource = context.coordinator
        tv.delegate = context.coordinator

        let dateCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(dateColIDStr))
        dateCol.title = lte(LongTimeEphemerisKeys.dateHeader)
        dateCol.width = dateColWidth
        dateCol.minWidth = 100
        dateCol.headerCell.alignment = .left
        tv.addTableColumn(dateCol)

        scrollView.documentView = tv
        context.coordinator.tableView = tv
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let tv = scrollView.documentView as? NSTableView else { return }

        context.coordinator.rows = rows
        context.coordinator.coordinate = coordinate
        context.coordinator.displayFormat = displayFormat

        // Rebuild factor columns on every update so order and selection stay in sync.
        for col in tv.tableColumns where col.identifier.rawValue != dateColIDStr {
            tv.removeTableColumn(col)
        }
        for factor in factors {
            let colID = NSUserInterfaceItemIdentifier("lte.factor.\(factor.rawValue)")
            let col = NSTableColumn(identifier: colID)
            col.width = valueColWidth
            col.minWidth = 60
            // Plain text name, right-aligned, system font — no custom glyph font needed.
            col.headerCell.title = factorName(factor)
            col.headerCell.alignment = .right
            tv.addTableColumn(col)
        }

        tv.reloadData()
    }

    // MARK: Coordinator

    final class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var rows: [LongTimeEphemerisRow] = []
        var coordinate: EphemerisCoordinate = .longitude
        var displayFormat: LongTimeEphemerisDisplayFormat = .dms
        weak var tableView: NSTableView?

        private let monoFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        private let cellID = NSUserInterfaceItemIdentifier("lte.cell")

        // Paragraph styles used in attributed strings; these ensure right/left
        // alignment even when attributedStringValue overrides textField.alignment.
        private let rightPara: NSParagraphStyle = {
            let s = NSMutableParagraphStyle()
            s.alignment = .right
            s.lineBreakMode = .byTruncatingTail
            return s
        }()
        private let leftPara: NSParagraphStyle = {
            let s = NSMutableParagraphStyle()
            s.alignment = .left
            s.lineBreakMode = .byTruncatingTail
            return s
        }()

        func numberOfRows(in tableView: NSTableView) -> Int { rows.count }

        func tableView(_ tableView: NSTableView,
                       viewFor tableColumn: NSTableColumn?,
                       row: Int) -> NSView? {
            guard let col = tableColumn, row < rows.count else { return nil }

            let cell = tableView.makeView(withIdentifier: cellID, owner: nil) as? LteTextCell
                ?? LteTextCell()
            cell.identifier = cellID

            let dataRow = rows[row]
            let colIDStr = col.identifier.rawValue

            if colIDStr == "lte.date" {
                cell.textField?.attributedStringValue = NSAttributedString(
                    string: dataRow.dateTimeString,
                    attributes: [.font: monoFont, .paragraphStyle: leftPara]
                )
            } else if let rawStr = colIDStr.components(separatedBy: ".").last,
                      let rawVal = Int(rawStr),
                      let factor = Factors(rawValue: rawVal),
                      let value = dataRow.values[factor] {
                cell.textField?.attributedStringValue = formattedAttr(value)
            } else {
                cell.textField?.attributedStringValue = NSAttributedString(
                    string: "—",
                    attributes: [.font: monoFont, .paragraphStyle: rightPara]
                )
            }

            return cell
        }

        private func formattedAttr(_ value: Double) -> NSAttributedString {
            let text: String
            switch displayFormat {
            case .decimal:
                text = String(format: "%.4f", value)
            case .dms:
                return dmsAttr(value)
            }
            return NSAttributedString(string: text,
                                      attributes: [.font: monoFont, .paragraphStyle: rightPara])
        }

        private func dmsAttr(_ value: Double) -> NSAttributedString {
            let text: String
            switch coordinate {
            case .longitude:
                let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(value)
                if let sign {
                    text = dms + " " + signAbbreviation(sign)
                } else {
                    text = dms
                }
            case .distance:
                text = String(format: "%.5f", value)
            default:
                text = PositionInDegreesConversion.DoubleToDms(value)
            }
            return NSAttributedString(string: text,
                                      attributes: [.font: monoFont, .paragraphStyle: rightPara])
        }
    }
}

private final class LteTextCell: NSTableCellView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        let tf = NSTextField(labelWithString: "")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.drawsBackground = false
        tf.isBordered = false
        tf.isEditable = false
        addSubview(tf)
        NSLayoutConstraint.activate([
            tf.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            tf.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            tf.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        textField = tf
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - CSV export (macOS)

private struct LteCsvExporter {
    static func export(
        to url: URL,
        rows: [LongTimeEphemerisRow],
        factors: [Factors],
        coordinate: EphemerisCoordinate,
        displayFormat: LongTimeEphemerisDisplayFormat
    ) {
        var lines: [String] = []

        // Header row
        var headerFields = [lte(LongTimeEphemerisKeys.dateHeader)]
        headerFields += factors.map { factorName($0) }
        lines.append(csvLine(headerFields))

        // Data rows
        for row in rows {
            var fields = [row.dateTimeString]
            for factor in factors {
                if let value = row.values[factor] {
                    fields.append(formattedText(value, coordinate: coordinate, displayFormat: displayFormat))
                } else {
                    fields.append("")
                }
            }
            lines.append(csvLine(fields))
        }

        let content = lines.joined(separator: "\n")
        try? content.write(to: url, atomically: true, encoding: .utf8)
    }

    // RFC 4180 quoting: all fields are double-quoted; any " inside is doubled.
    private static func csvLine(_ fields: [String]) -> String {
        fields.map { "\"" + $0.replacingOccurrences(of: "\"", with: "\"\"") + "\"" }
              .joined(separator: ",")
    }

    private static func formattedText(
        _ value: Double,
        coordinate: EphemerisCoordinate,
        displayFormat: LongTimeEphemerisDisplayFormat
    ) -> String {
        switch displayFormat {
        case .decimal:
            return String(format: "%.4f", value)
        case .dms:
            switch coordinate {
            case .longitude:
                let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(value)
                if let sign { return dms + " " + signAbbreviation(sign) }
                return dms
            case .distance:
                return String(format: "%.5f", value)
            default:
                return PositionInDegreesConversion.DoubleToDms(value)
            }
        }
    }
}
#endif

// MARK: - iOS: SwiftUI scroll table

#if !os(macOS)
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct LteScrollTable: View {
    @EnvironmentObject private var model: LongTimeEphemerisModel

    private let dateColWidth: CGFloat  = 156
    private let valueColWidth: CGFloat = 130
    private let cellPadH: CGFloat      = 6
    private let headerHeight: CGFloat  = 32
    private let rowPadV: CGFloat       = 3

    private var dateColTotalWidth: CGFloat { dateColWidth + 2 * cellPadH }

    @State private var verticalScrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .top, spacing: 0) {
                dateColumn
                    .offset(y: -verticalScrollOffset)
                    .frame(width: dateColTotalWidth, height: proxy.size.height, alignment: .top)
                    .clipped()
                    .background(Color(UIColor.systemBackground))

                Rectangle()
                    .fill(Color.primary.opacity(0.3))
                    .frame(width: 1)

                ScrollView([.horizontal, .vertical]) {
                    factorContent
                }
                .defaultScrollAnchor(.topLeading)
                .coordinateSpace(name: "lteTableScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    verticalScrollOffset = offset
                }
                .scrollIndicators(.visible)
                .frame(height: proxy.size.height)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var dateColumn: some View {
        VStack(spacing: 0) {
            Text(lte(LongTimeEphemerisKeys.dateHeader))
                .fontWeight(.semibold)
                .frame(width: dateColWidth, alignment: .leading)
                .frame(height: headerHeight)
                .padding(.horizontal, cellPadH)
                .background(Color.primary.opacity(0.10))
            Divider()
            LazyVStack(spacing: 0) {
                ForEach(model.rows) { row in
                    Text(row.dateTimeString)
                        .frame(width: dateColWidth, alignment: .leading)
                        .padding(.horizontal, cellPadH)
                        .padding(.vertical, rowPadV)
                        .background(row.id % 2 == 0 ? Color.primary.opacity(0.06) : Color.clear)
                }
            }
        }
        .font(.system(.body, design: .monospaced))
        .frame(width: dateColTotalWidth)
    }

    private var factorContent: some View {
        factorColumns
            // horizontal: true preserves column widths for horizontal scrolling;
            // vertical: false keeps LazyVStack lazy (avoids eager layout of all rows).
            .fixedSize(horizontal: true, vertical: false)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: -geo.frame(in: .named("lteTableScroll")).origin.y
                    )
                }
            )
    }

    private var factorColumns: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Factor names as column headers (plain text, no custom glyph font)
            HStack(spacing: 0) {
                ForEach(model.selectedFactors, id: \.rawValue) { factor in
                    Text(factorName(factor))
                        .fontWeight(.semibold)
                        .frame(width: valueColWidth, alignment: .trailing)
                        .frame(height: headerHeight)
                        .padding(.horizontal, cellPadH)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
            .background(Color.primary.opacity(0.10))
            Divider()
            LazyVStack(spacing: 0) {
                ForEach(model.rows) { row in
                    HStack(spacing: 0) {
                        ForEach(model.selectedFactors, id: \.rawValue) { factor in
                            formattedCell(row: row, factor: factor)
                                .frame(width: valueColWidth, alignment: .trailing)
                                .padding(.horizontal, cellPadH)
                                .padding(.vertical, rowPadV)
                        }
                    }
                    .font(.system(.body, design: .monospaced))
                    .background(row.id % 2 == 0 ? Color.primary.opacity(0.06) : Color.clear)
                }
            }
        }
    }

    @ViewBuilder
    private func formattedCell(row: LongTimeEphemerisRow, factor: Factors) -> some View {
        if let value = row.values[factor] {
            switch model.displayFormat {
            case .decimal:
                Text(String(format: "%.4f", value))
            case .dms:
                dmsCell(value: value)
            }
        } else {
            Text("—").foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func dmsCell(value: Double) -> some View {
        switch model.selectedCoordinate {
        case .longitude:
            let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(value)
            if let sign {
                // Sign abbreviation uses the same monospaced font — no custom font switch needed.
                Text(dms + " " + signAbbreviation(sign))
            } else {
                Text(dms)
            }
        case .distance:
            Text(String(format: "%.5f", value))
        default:
            Text(PositionInDegreesConversion.DoubleToDms(value))
        }
    }
}
#endif
