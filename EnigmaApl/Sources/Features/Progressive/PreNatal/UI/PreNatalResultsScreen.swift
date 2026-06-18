// PreNatalResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "PreNatal", bundle: .main, comment: "")
}

struct PreNatalResultsScreen: View {
    @EnvironmentObject private var model: PreNatalModel
    @EnvironmentObject private var chartSession: ChartSession

    @State private var showHelp = false
    @State private var showFactsheet = false

    // Column widths
    private let dateW:     CGFloat = 110   // actual date yyyy/mm/dd
    private let typeW:     CGFloat = 100   // type: up to 3 astrological glyphs
    private let glyphW:    CGFloat = 30    // factor or sign glyph
    private let posW:      CGFloat = 88    // dms longitude
    private let prenatalW: CGFloat = 200   // prenatal date/time yyyy/mm/dd hh:mm:ss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(PreNatalKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name).font(.headline).foregroundStyle(.secondary)
                }

                if model.isCalculating {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(t(PreNatalKeys.calculating)).foregroundStyle(.secondary).font(.callout)
                    }
                } else if model.hasResults {
                    momentsTable
                } else if let err = model.errorMessage {
                    Text(err).font(.callout).foregroundStyle(.red)
                } else {
                    Text(t(PreNatalKeys.noResults)).foregroundStyle(.secondary).font(.callout)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(PreNatalKeys.resultsTitle))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: { Image(systemName: "book.pages") }
                    .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: { Image(systemName: "questionmark.circle") }
                    .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "prenatal")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(PreNatalKeys.helpResults))
        }
    }

    // MARK: - Table

    private var momentsTable: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    tableHeader
                    Divider()
                    ForEach(Array(model.moments.enumerated()), id: \.offset) { idx, moment in
                        momentRow(moment, index: idx)
                    }
                }
            }
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 4) {
            Text(t(PreNatalKeys.colActualDate))
                .frame(width: dateW, alignment: .leading)
            Text(t(PreNatalKeys.colType))
                .frame(width: typeW, alignment: .leading)
            Spacer().frame(width: glyphW)   // factor 1 glyph
            Spacer().frame(width: posW)     // longitude 1
            Spacer().frame(width: glyphW)   // sign 1 glyph
            Spacer().frame(width: glyphW)   // factor 2 glyph
            Spacer().frame(width: posW)     // longitude 2
            Spacer().frame(width: glyphW)   // sign 2 glyph
            Text(t(PreNatalKeys.colPrenatalDate))
                .frame(width: prenatalW, alignment: .leading)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func momentRow(_ moment: PreNatalMoment, index: Int) -> some View {
        let (f1Glyph, dms1, sign1Glyph, f2Glyph, dms2, sign2Glyph) = displayFields(for: moment)
        let isSelected = model.selectedMomentJD == moment.actualJD
        return HStack(spacing: 4) {
            // Col 1: Actual date
            Text(moment.actualDateTxt)
                .frame(width: dateW, alignment: .leading)
                .font(.body.monospacedDigit())

            // Col 2: Type glyphs
            typeColumnView(for: moment)
                .frame(width: typeW, alignment: .leading)

            // Col 3: Factor 1 glyph
            Text(f1Glyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)

            // Col 4: Longitude 1
            Text(dms1)
                .frame(width: posW, alignment: .leading)
                .font(.body.monospacedDigit())

            // Col 5: Sign 1 glyph
            Text(sign1Glyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)

            // Col 6: Factor 2 glyph
            if let g2 = f2Glyph {
                Text(g2).font(.custom("EnigmaAstrology2", size: 18)).frame(width: glyphW, alignment: .center)
            } else {
                Spacer().frame(width: glyphW)
            }

            // Col 7: Longitude 2
            if let d2 = dms2 {
                Text(d2).frame(width: posW, alignment: .leading).font(.body.monospacedDigit())
            } else {
                Spacer().frame(width: posW)
            }

            // Col 8: Sign 2 glyph
            if let s2 = sign2Glyph {
                Text(s2).font(.custom("EnigmaAstrology2", size: 18)).frame(width: glyphW, alignment: .center)
            } else {
                Spacer().frame(width: glyphW)
            }

            // Col 9: Prenatal date + time
            Text(moment.prenatalDateTxt)
                .frame(width: prenatalW, alignment: .leading)
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isSelected
            ? Color.accentColor.opacity(0.2)
            : (index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06)))
        .contentShape(Rectangle())
        .onTapGesture {
            model.selectedMomentJD = (isSelected ? nil : moment.actualJD)
        }
    }

    // MARK: - Type column

    @ViewBuilder
    private func typeColumnView(for moment: PreNatalMoment) -> some View {
        switch moment.kind {
        case .solarEclipse:
            Text(GlyphSelector.getGlyphForFactor(.blackSun))
                .font(.custom("EnigmaAstrology2", size: 18))
        case .lunarEclipse:
            // apogeeMean is the classical Black Moon (Lilith) glyph
            Text(GlyphSelector.getGlyphForFactor(.apogeeMean))
                .font(.custom("EnigmaAstrology2", size: 18))
        case .aspect(let aspectKind, let f1, let f2):
            Text(GlyphSelector.getGlyphForFactor(f1)
                 + GlyphSelector.getGlyphForAspect(aspectKind)
                 + GlyphSelector.getGlyphForFactor(f2))
                .font(.custom("EnigmaAstrology2", size: 18))
        case .ingress(let factor, let sign):
            Text(GlyphSelector.getGlyphForFactor(factor)
                 + GlyphSelector.getGlyphForSign(sign))
                .font(.custom("EnigmaAstrology2", size: 18))
        case .retrograde(let factor):
            HStack(spacing: 1) {
                Text(GlyphSelector.getGlyphForFactor(factor))
                    .font(.custom("EnigmaAstrology2", size: 18))
                Text("Rx").font(.caption).foregroundStyle(.secondary)
            }
        case .direct(let factor):
            HStack(spacing: 1) {
                Text(GlyphSelector.getGlyphForFactor(factor))
                    .font(.custom("EnigmaAstrology2", size: 18))
                Text("D").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Display helpers

    private func displayFields(for moment: PreNatalMoment) -> (
        f1Glyph: String, dms1: String, sign1Glyph: String,
        f2Glyph: String?, dms2: String?, sign2Glyph: String?
    ) {
        let (dms1, sign1) = dmsSign(moment.longitude1)
        let sign1Glyph = sign1.map { GlyphSelector.getGlyphForSign($0) } ?? "?"

        switch moment.kind {
        case .solarEclipse:
            return (GlyphSelector.getGlyphForFactor(.sun), dms1, sign1Glyph, nil, nil, nil)
        case .lunarEclipse:
            return (GlyphSelector.getGlyphForFactor(.sun), dms1, sign1Glyph, nil, nil, nil)
        case .ingress(let factor, _):
            return (GlyphSelector.getGlyphForFactor(factor), dms1, sign1Glyph, nil, nil, nil)
        case .retrograde(let factor):
            return (GlyphSelector.getGlyphForFactor(factor), dms1, sign1Glyph, nil, nil, nil)
        case .direct(let factor):
            return (GlyphSelector.getGlyphForFactor(factor), dms1, sign1Glyph, nil, nil, nil)
        case .aspect(_, let f1, let f2):
            let (dms2, sign2) = moment.longitude2.map { dmsSign($0) } ?? ("", nil)
            let sign2Glyph = sign2.map { GlyphSelector.getGlyphForSign($0) }
            return (GlyphSelector.getGlyphForFactor(f1), dms1, sign1Glyph,
                    GlyphSelector.getGlyphForFactor(f2), dms2.isEmpty ? nil : dms2, sign2Glyph)
        }
    }

    private func dmsSign(_ longitude: Double) -> (String, Signs?) {
        let (dms, sign, ok) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
        return ok ? (dms, sign) : (PositionInDegreesConversion.DoubleToDms(longitude), nil)
    }
}
