// VspScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct VspScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var vspModel:     VspModel
    @State private var showHelp      = false
    @State private var showFactsheet = false

    private let seqW:    CGFloat = 36
    private let nameW:   CGFloat = 60
    private let phenW:   CGFloat = 100
    private let dateW:   CGFloat = 170
    private let posW:    CGFloat = 80
    private let glyphW:  CGFloat = 30

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(VspKeys.title),
                    systemImage: "star.circle",
                    description: Text(t(VspKeys.noChart))
                )
            } else {
                content
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "vsp")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(VspKeys.help))
        }
        .onAppear { vspModel.refresh(chart: chartSession.selectedChart) }
        .onChange(of: chartSession.selectedChart?.JulianDay) {
            vspModel.refresh(chart: chartSession.selectedChart)
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(t(VspKeys.title))
                    .font(.title2.weight(.semibold))

                Text(t(VspKeys.explanation))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                positionsTable
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    // MARK: - Table

    private var positionsTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                headerRow
                Divider()
                ForEach(Array(vspModel.positions.enumerated()), id: \.element.id) { index, pos in
                    dataRow(pos, index: index)
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text(t(VspKeys.colSeq))
                .frame(width: seqW, alignment: .center)
            Text(t(VspKeys.colName))
                .frame(width: nameW, alignment: .leading)
            Text(t(VspKeys.colPhenomenon))
                .frame(width: phenW, alignment: .leading)
            Text(t(VspKeys.colDate))
                .frame(width: dateW, alignment: .leading)
            Text(t(VspKeys.colLongitude))
                .frame(width: posW, alignment: .trailing)
            Spacer().frame(width: glyphW)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func dataRow(_ pos: PresentableVspPosition, index: Int) -> some View {
        let (dmsText, sign, valid) = PositionInDegreesConversion.DoubleToDmsSign(pos.longitude)
        let glyphText = valid ? GlyphSelector.getGlyphForSign(sign!) : ""

        HStack(spacing: 8) {
            Text("\(pos.sequenceId)")
                .font(.headline)
                .frame(width: seqW, alignment: .center)
            Text(positionName(pos.sequenceId))
                .frame(width: nameW, alignment: .leading)
            Text(phenomenonText(pos.phenomenon))
                .frame(width: phenW, alignment: .leading)
            Text(pos.dateText)
                .frame(width: dateW, alignment: .leading)
                .font(.system(.body, design: .monospaced))
            Text(dmsText)
                .frame(width: posW, alignment: .trailing)
                .font(.system(.body, design: .monospaced))
            Text(glyphText)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Helpers

    private func positionName(_ seq: Int) -> String {
        switch seq {
        case 1, 5: return t(VspKeys.nameLeg)
        case 2, 4: return t(VspKeys.nameArm)
        case 3:    return t(VspKeys.nameHead)
        default:   return "–"
        }
    }

    private func phenomenonText(_ phenomenon: VenusPhenomena) -> String {
        switch phenomenon {
        case .inferiorConjunction: return t(VspKeys.phenInferior)
        case .superiorConjunction: return t(VspKeys.phenSuperior)
        }
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Vsp", bundle: .main, comment: "")
    }
}
