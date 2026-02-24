//
//  ConfigNewFormView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 14/02/2026.
//

import SwiftUI

/// Left pane: complex form for creating a new config.
struct ConfigNewFormView: View {
    @ObservedObject var view: ConfigNewModel
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("New")
                    .font(.title2)
                    .bold()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                    TextField(
                        "E.g. Projectconfig A",
                        text: Binding(
                            get: { view.name },
                            set: { view.updateName($0) }
                        )
                    )
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Type")
                        .font(.headline)

                    Picker(
                        "Type",
                        selection: Binding(
                            get: { view.type },
                            set: { view.updateType($0) }
                        )
                    ) {
                        ForEach(ConfigNewModel.ConfigType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Toggle(
                    "Active",
                    isOn: Binding(
                        get: { view.isActive },
                        set: { view.updateIsActive($0) }
                    )
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Remarks")
                        .font(.headline)
                    TextEditor(
                        text: Binding(
                            get: { view.remarks },
                            set: { view.updateRemarks($0) }
                        )
                    )
                        .frame(minHeight: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.35))
                        )
                }

                HStack(spacing: 12) {
                    Button("Save") {
                        // Leerproject: save-flow volgt later.
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Close", action: onClose)
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
