// InputColumnWidth.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

// Makes a column of the NavigationSplitView at least as wide as its widest input row.
// Input rows for date, time and location have a fixed width (`inputRowWidth()`) and report the width they need.
// The column (`fitsInputRows()`) uses the largest reported width as its minimum, so the divider moves
// automatically when a screen with wider input is opened. People can still drag the divider, down to that minimum.

private let inputColumnSpace = "inputColumn"

/// Space kept to the right of the widest input row, e.g. for padding and a scroller.
private let trailingMargin: CGFloat = 16

private struct RequiredInputWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    /// Gives an input row its natural width and reports that width to the enclosing column.
    func inputRowWidth() -> some View {
        fixedSize(horizontal: true, vertical: false)
            .background(
                GeometryReader { geo in
                    let frame = geo.frame(in: .named(inputColumnSpace))
                    // maxX covers the leading insets when the row fits; width covers a row that overflows
                    // and is centered by its container.
                    Color.clear.preference(key: RequiredInputWidthKey.self,
                                           value: max(frame.maxX + trailingMargin, frame.width + 2 * trailingMargin))
                }
            )
    }

    /// Sets the minimum width of a split view column to the widest input row it contains.
    func fitsInputRows() -> some View {
        modifier(FitsInputRows())
    }
}

private struct FitsInputRows: ViewModifier {
    @State private var requiredWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: inputColumnSpace)
            .onPreferenceChange(RequiredInputWidthKey.self) { width in
                let rounded = width.rounded(.up)
                if rounded != requiredWidth { requiredWidth = rounded }
            }
            .frame(minWidth: requiredWidth > 0 ? requiredWidth : nil)
    }
}
