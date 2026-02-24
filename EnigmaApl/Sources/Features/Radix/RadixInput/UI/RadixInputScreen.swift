//
//  RadixInputScreen.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 23/02/2026.
//

import SwiftUI

enum LatitudeHemisphere: String, CaseIterable, Identifiable {
    case north = "N"
    case south = "Z"
    var id: String { rawValue }
}

enum LongitudeHemisphere: String, CaseIterable, Identifiable {
    case east = "O"
    case west = "W"
    var id: String { rawValue }
}

/// Apple-conforme segmented control met optionele titel.
/// - Goede a11y: label + value + hint
/// - Werkt netjes in Forms
/// - Titel kan weg, maar a11y label blijft bestaan
struct HemisphereSegmented<Option>: View where Option: Hashable & Identifiable {
    private let title: LocalizedStringKey?
    private let a11yLabel: LocalizedStringKey
    private let hint: LocalizedStringKey?
    private let options: [Option]
    private let label: (Option) -> LocalizedStringKey
    @Binding private var selection: Option

    /// Initializer met (optionele) titel.
    init(
        title: LocalizedStringKey? = nil,
        accessibilityLabel: LocalizedStringKey? = nil,
        hint: LocalizedStringKey? = nil,
        options: [Option],
        label: @escaping (Option) -> LocalizedStringKey,
        selection: Binding<Option>
    ) {
        self.title = title
        // Als je geen accessibilityLabel opgeeft, gebruiken we de titel,
        // en als die ook ontbreekt een generieke fallback.
        self.a11yLabel = accessibilityLabel ?? title ?? "Keuze"
        self.hint = hint
        self.options = options
        self.label = label
        self._selection = selection
    }

    /// Initializer zonder titel (handig voor compacte UI).
    init(
        options: [Option],
        label: @escaping (Option) -> LocalizedStringKey,
        selection: Binding<Option>,
        accessibilityLabel: LocalizedStringKey,
        hint: LocalizedStringKey? = nil
    ) {
        self.init(
            title: nil,
            accessibilityLabel: accessibilityLabel,
            hint: hint,
            options: options,
            label: label,
            selection: selection
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
            }

            Picker("", selection: $selection) {
                ForEach(options) { option in
                    Text(label(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
            // Zorg dat het ook zonder visuele titel toegankelijk blijft
            .accessibilityLabel(a11yLabel)
            .accessibilityValue(label(selection))
            .accessibilityHint(hint ?? "")
        }
    }
}


struct RadixInputMetaDataView: View {
    @State private var chartName: String = ""
    @State private var description = ""
    @State private var source = ""
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Describe the chart").bold()
            TextField("Name", text: $chartName)
                .textFieldStyle(.roundedBorder)
       
            TextField("Description", text: $description)
                .textFieldStyle(.roundedBorder)
            TextField("Source", text: $source)
                .textFieldStyle(.roundedBorder)
        }.padding(  10)

    }
}

struct RadixInputLocationView: View {
    @State private var locationName: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var latHemi: LatitudeHemisphere = .north
    @State private var lonHemi: LongitudeHemisphere = .east
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Describe the location").bold()
            HStack{
                Text("City")
                TextField("Name of location", text: $locationName)  .textFieldStyle(.roundedBorder)

            }
  
            HStack{
                Text("Longitude")
                TextField("ddd:mm:ss", text: $longitude)  .textFieldStyle(.roundedBorder)
                HemisphereSegmented(
                    options: LongitudeHemisphere.allCases,
                    label: { LocalizedStringKey($0.rawValue) },
                    selection: $lonHemi,
                    accessibilityLabel: "Lengtegraad",
                    hint: "Kies oost of west"
                )
                Spacer()
                Text("Latitude")
                TextField("dd:mm:ss", text: $latitude)  .textFieldStyle(.roundedBorder)
                HemisphereSegmented(
                    options: LatitudeHemisphere.allCases,
                    label: { LocalizedStringKey($0.rawValue) },
                    selection: $latHemi,
                    accessibilityLabel: "Breedtegraad",
                    hint: "Kies noord of zuid"
                )
            }


        }.padding(10)
    }
    
}



struct RadixInputScreen: View {
    var body: some View {
        RadixInputMetaDataView()
        RadixInputLocationView()
    }
}

#Preview {
    RadixInputScreen()
}
