// EclipsesPDFExporter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import AppKit
import CoreText
import UniformTypeIdentifiers

struct EclipsesPDFExporter {

    // MARK: - Page geometry

    private static let pageW: CGFloat   = 595   // A4 portrait
    private static let pageH: CGFloat   = 842
    private static let marginL: CGFloat = 40
    private static let marginT: CGFloat = 40
    private static let marginB: CGFloat = 40
    private static let rowH: CGFloat    = 17
    private static let hdrH: CGFloat    = 20
    private static let titleH: CGFloat  = 32

    // MARK: - Public entry point

    static func export(events: [EclipseEvent],
                       hasLocation: Bool,
                       seWrapper: SEWrapper) -> Data? {
        var mediaBox = CGRect(x: 0, y: 0, width: pageW, height: pageH)
        let pdfData  = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
              let ctx      = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)
        else { return nil }

        let bodyFont  = NSFont.monospacedSystemFont(ofSize: 9.5, weight: .regular)
        let hdrFont   = NSFont.monospacedSystemFont(ofSize: 9.5, weight: .bold)
        let titleFont = NSFont.systemFont(ofSize: 13, weight: .semibold)
        let glyphFont = NSFont(name: "EnigmaAstrology3", size: 10.5) ?? bodyFont

        // Column definitions differ for global vs local table
        let cols: [(label: String, width: CGFloat)] = hasLocation
            ? [("",          24),
               ("Date/Time", 145),
               ("Position",  112),
               ("Type",       90),
               ("Visible",    60),
               ("Saros",      84)]
            : [("",           24),
               ("Date/Time", 200),
               ("Position",  291)]

        let tableW = cols.reduce(0.0) { $0 + $1.width }

        // State for pagination
        var yTop: CGFloat = 0
        var isFirstPage  = true

        func beginPage() {
            ctx.beginPDFPage(nil)
            yTop = pageH - marginT

            if isFirstPage {
                // Title
                let titleAttr = attributed("Eclipses", font: titleFont)
                drawLine(ctx: ctx, attrStr: titleAttr, x: marginL, baseline: yTop - titleH + 8)
                yTop -= titleH
                isFirstPage = false
            }

            // Header row background
            ctx.setFillColor(NSColor.systemGray.withAlphaComponent(0.18).cgColor)
            ctx.fill(CGRect(x: marginL, y: yTop - hdrH, width: tableW, height: hdrH))

            // Header labels
            var cx = marginL
            for col in cols {
                let a = attributed(col.label, font: hdrFont)
                drawLine(ctx: ctx, attrStr: a, x: cx + 3, baseline: yTop - hdrH + 4)
                cx += col.width
            }
            yTop -= hdrH
        }

        func endPage() {
            ctx.endPDFPage()
        }

        beginPage()

        for (idx, event) in events.enumerated() {
            if yTop - rowH < marginB {
                endPage()
                beginPage()
            }

            // Alternating row tint
            if idx % 2 == 0 {
                ctx.setFillColor(NSColor.systemGray.withAlphaComponent(0.06).cgColor)
                ctx.fill(CGRect(x: marginL, y: yTop - rowH, width: tableW, height: rowH))
            }

            let base = yTop - rowH + 3
            var cx   = marginL

            // Eclipse kind glyph
            let kindGlyph = event.kind == .solar ? "\u{F360}" : "\u{F361}"
            drawLine(ctx: ctx, attrStr: attributed(kindGlyph, font: glyphFont), x: cx + 3, baseline: base)
            cx += cols[0].width

            // Date / time
            drawLine(ctx: ctx,
                     attrStr: attributed(formatDateTime(event.displayJD, seWrapper: seWrapper), font: bodyFont),
                     x: cx + 3, baseline: base)
            cx += cols[1].width

            // Position: degrees in body font + sign glyph in glyph font
            let posAttr = mixedAttributed(
                text: formatDegrees(event.longitude) + " ",
                textFont: bodyFont,
                glyph: signGlyphChar(event.longitude),
                glyphFont: glyphFont
            )
            drawLine(ctx: ctx, attrStr: posAttr, x: cx + 3, baseline: base)
            cx += cols[2].width

            if hasLocation {
                // Type
                drawLine(ctx: ctx,
                         attrStr: attributed(typeLabel(event), font: bodyFont),
                         x: cx + 3, baseline: base)
                cx += cols[3].width

                // Visible: ✓ (green) / ✗ (gray) / — (gray)
                let visAttr: NSAttributedString
                if event.hasLocalData {
                    if event.isVisible {
                        visAttr = attributed("\u{2713}", font: bodyFont, color: .systemGreen)
                    } else {
                        visAttr = attributed("\u{2717}", font: bodyFont, color: .systemGray)
                    }
                } else {
                    visAttr = attributed("—", font: bodyFont, color: .systemGray)
                }
                drawLine(ctx: ctx, attrStr: visAttr, x: cx + 3, baseline: base)
                cx += cols[4].width

                // Saros
                let sarosText = event.sarosNumber > -99999998
                    ? "\(Int(event.sarosNumber))-\(Int(event.sarosMemberNumber))"
                    : "—"
                drawLine(ctx: ctx,
                         attrStr: attributed(sarosText, font: bodyFont),
                         x: cx + 3, baseline: base)
            }

            yTop -= rowH
        }

        endPage()
        ctx.closePDF()
        return pdfData as Data
    }

    // MARK: - Save panel

    static func saveWithPanel(data: Data, defaultName: String = "Eclipses.pdf") {
        let panel = NSSavePanel()
        panel.allowedContentTypes  = [.pdf]
        panel.nameFieldStringValue = defaultName
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? data.write(to: url)
        }
    }

    // MARK: - Core Text drawing

    private static func drawLine(ctx: CGContext, attrStr: NSAttributedString,
                                 x: CGFloat, baseline: CGFloat) {
        let line = CTLineCreateWithAttributedString(attrStr)
        ctx.textMatrix   = .identity
        ctx.textPosition = CGPoint(x: x, y: baseline)
        CTLineDraw(line, ctx)
    }

    // MARK: - Attributed string helpers

    private static func attributed(_ text: String, font: NSFont,
                                   color: NSColor = .black) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font:            font,
            .foregroundColor: color
        ])
    }

    private static func mixedAttributed(text: String, textFont: NSFont,
                                        glyph: String, glyphFont: NSFont) -> NSAttributedString {
        let result = NSMutableAttributedString(string: text, attributes: [
            .font: textFont, .foregroundColor: NSColor.black
        ])
        result.append(NSAttributedString(string: glyph, attributes: [
            .font: glyphFont, .foregroundColor: NSColor.black
        ]))
        return result
    }

    // MARK: - Formatting (mirrors EclipsesResultsScreen helpers)

    private static func formatDateTime(_ jd: Double, seWrapper: SEWrapper) -> String {
        let dt     = seWrapper.dateFromJulianDay(jd)
        let hour   = Int(dt.Time.HourDecimal)
        let minute = Int((dt.Time.HourDecimal - Double(hour)) * 60)
        return String(format: "%d-%02d-%02d %02d:%02d",
                      dt.Date.Year, dt.Date.Month, dt.Date.Day, hour, minute)
    }

    private static func formatDegrees(_ longitude: Double) -> String {
        let posInSign = longitude - Double(Int(longitude / 30)) * 30
        let deg       = Int(posInSign)
        let minFrac   = (posInSign - Double(deg)) * 60
        let min       = Int(minFrac)
        let sec       = Int((minFrac - Double(min)) * 60)
        return String(format: "%2d\u{00B0}%02d'%02d\"", deg, min, sec)
    }

    private static func signGlyphChar(_ longitude: Double) -> String {
        let sign = Signs(rawValue: Int(longitude / 30) + 1) ?? .Aries
        return GlyphSelector.getGlyphForSign(sign)
    }

    private static func typeLabel(_ event: EclipseEvent) -> String {
        if event.isTotal     { return "Total" }
        if event.isAnnular   { return "Annular" }
        if event.isPenumbral { return "Penumbral" }
        if event.isPartial   { return "Partial" }
        return "—"
    }
}
