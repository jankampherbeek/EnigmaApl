//
//  RadixInput.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 15/12/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct RadixInput: View {
    @Environment(\.dismiss) private var dismiss
    @State private var chartName: String = ""
    @State private var description: String = ""
    @State private var dateString: String = ""
    @State private var timeString: String = ""
    @State private var selectedHouseSystem: HouseSystemOption = .placidus
    
    enum HouseSystemOption: String, CaseIterable {
        case placidus = "Placidus"
        case regiomontanus = "Regiomontanus"
        case equalAscendant = "Equal ascendant"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("Data for chart")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
#if os(macOS)
            .background(Color(NSColor.windowBackgroundColor))
#else
            .background(Color(UIColor.systemBackground))
#endif
            
            Divider()
            
            // Form content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chart name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Chart name", text: $chartName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Description", text: $description)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("yyyy/mm/dd", text: $dateString)
                            .textFieldStyle(.roundedBorder)
#if os(iOS)
                            .keyboardType(UIKeyboardType.numbersAndPunctuation)
                            .autocapitalization(UITextAutocapitalizationType.none)
                            .disableAutocorrection(true)
#endif
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("hh:mm:ss", text: $timeString)
                            .textFieldStyle(.roundedBorder)
#if os(iOS)
                            .keyboardType(UIKeyboardType.numbersAndPunctuation)
                            .autocapitalization(UITextAutocapitalizationType.none)
                            .disableAutocorrection(true)
#endif
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("House systems")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("House systems", selection: $selectedHouseSystem) {
                            ForEach(HouseSystemOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Button(action: calculate) {
                        HStack {
                            Spacer()
                            Text("Calculate")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func calculate() {
        // TODO: Implement calculation logic
        print("Calculate button pressed")
        print("Chart name: \(chartName)")
        print("Description: \(description)")
        print("Date: \(dateString)")
        print("Time: \(timeString)")
        print("House system: \(selectedHouseSystem.rawValue)")
    }
}

#Preview {
    RadixInput()
}
