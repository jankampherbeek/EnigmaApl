// AboutView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct AboutView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(t(AboutKeys.title))
                .font(.title)
                .bold()

            Text(t(AboutKeys.description))

            Text(t(AboutKeys.contributors))

            Text(t(AboutKeys.names))
                .italic()

            Spacer()

            HStack {
                Spacer()
                Button(NSLocalizedString(SharedKeys.close, tableName: "Shared", bundle: .main, comment: "")) { dismissWindow(id: "about") }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(minWidth: 480, minHeight: 280)
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "About", bundle: .main, comment: "")
    }
}
