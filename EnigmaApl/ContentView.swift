//
//  ContentView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 15/12/2025.
//

import SwiftUI
import SwiftData
#if os(macOS)
import AppKit
#else
import UIKit
#endif


struct ContentView: View {
   // @ObservedObject var model: AppShellModel
    //    @Environment(\.modelContext) private var modelContext
    //    @Query private var items: [Item]
    //    @State private var sunLongitude: Double? = nil
    //    @State private var isCalculating: Bool = false
    //    @State private var showRadixInput: Bool = false
    //
    //    // SEWrapper instance passed from app level for thread-safety
    //    let seWrapper: SEWrapper
    //
    //    var availableFontFamilies: [String] {
    //        #if os(macOS)
    //        return NSFontManager.shared.availableFontFamilies.sorted()
    //        #else
    //        return UIFont.familyNames.sorted()
    //        #endif
    //    }
    
    var body: some View {
//        AppShellView(model: model)
        //        NavigationSplitView {
        //            List {
        //                ForEach(items) { item in
        //                    NavigationLink {
        //                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        //                    } label: {
        //                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        //                    }
        //                }
        //                .onDelete(perform: deleteItems)
        //            }
        //#if os(macOS)
        //            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        //#endif
        //            .toolbar {
        //#if os(iOS)
        //                ToolbarItem(placement: .navigationBarTrailing) {
        //                    EditButton()
        //                }
        //#endif
        //                ToolbarItem {
        //                    Button(action: addItem) {
        //                        Label("Add Item", systemImage: "plus")
        //                    }
        //                }
        //                ToolbarItem {
        //                    Button(action: { showRadixInput = true }) {
        //                        Label("Input", systemImage: "text.cursor")
        //                    }
        //                }
        //            }
        //            .sheet(isPresented: $showRadixInput) {
        //                RadixInput()
        //            }
        //        } detail: {
        //            VStack(alignment: .leading, spacing: 10) {
        //                Button(action: { showRadixInput = true }) {
        //                    Label("Input", systemImage: "text.cursor")
        //                        .font(.headline)
        //                        .padding()
        //                }
        //                .buttonStyle(.borderedProminent)
        //                .padding(.bottom, 10)
        //
        //                Text("The symbol for the Sun is \u{E200}")
        //                    .font(.custom("EnigmaAstrology2", size: 18))
        //                    .padding(.bottom, 5)
        //
        //                if let longitude = sunLongitude {
        //                    Text("Sun longitude: \(longitude, specifier: "%.6f") degrees")
        //                        .font(.headline)
        //                        .padding(.bottom, 5)
        //                }
        //
        //                Text("Available Font Families")
        //                    .font(.headline)
        //                    .padding(.bottom, 5)
        //
        //                Text("hello")
        //                // Alternative explicit approach for debugging:
        //                // Text(String(localized: "hello"))
        //
        //                ScrollView {
        //                    VStack(alignment: .leading, spacing: 5) {
        //                        ForEach(availableFontFamilies, id: \.self) { fontFamily in
        //                            Text(fontFamily)
        //                                .font(.system(size: 12))
        //                                .padding(.vertical, 2)
        //                        }
        //                    }
        //                }
        //            }
        //            .padding()
        //            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        //            .onAppear {
        //                // Prevent overlapping calculations - onAppear can be called multiple times
        //                guard !isCalculating else { return }
        //                isCalculating = true
        //                defer { isCalculating = false }
        //
        //                // SeTest.PerformTest() // Disabled: SeTest uses SwissEph which is kept for reference only
        //
        //                // Create ConfigData
        //                let configData = ConfigData(
        //                    houseSystem: .noHouses,
        //                    ayanamsha: .tropical,
        //                    observerPosition: .geoCentric,
        //                    projectionType: .obliqueLongitude,
        //                    blackMoonCorrectionType: .duval,
        //                    lunarNodeType: .meanNode,
        //                    lotsType: .sect
        //                )
        //
        //                // Create CalcRequest
        //                let calcRequest = CalcRequest(
        //                    JulianDay: 2455197.5,
        //                    FactorsToUse: [
        //                        .sun, .moon, .mercury, .venus, .mars,
        //                        .jupiter, .saturn, .uranus, .neptune, .pluto, .chiron,
        //                        .persephoneRam, .hermesRam, .demeterRam,
        //                        .persephoneCarteret, .vulcanusCarteret,
        //                        //.blackSun,
        //                        .diamond,
        //                        .apogeeMean,
        //                        .apogeeCorrected,
        //                            .priapus, .dragon, .beast, .southNode,
        //                        .parsfortuna
        //                    ],
        //                    HouseSystem: 0,
        //                    Latitude: 52.2180555555556,
        //                    Longitude: 6.8955555555556,
        //                    Height: 0.0,
        //                    ConfigData: configData
        //                )
        //
        //                // Perform calculation with the shared SEWrapper instance
        //                let fullChart = AstronCalcOrchestrator.PerformCalculation(calcRequest, seWrapper: seWrapper)
        //
        //                // Print all factors and positions to console
        //                print("\n=== All Factors and Positions ===")
        //                for (factor, position) in fullChart.Coordinates.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
        //                    print("\nFactor: \(factor)")
        //
        //                    // Ecliptical positions
        //                    if !position.ecliptical.isEmpty {
        //                        print("  Ecliptical:")
        //                        for (index, ecliptical) in position.ecliptical.enumerated() {
        //                            print("    [\(index)] Longitude: \(String(format: "%.6f", ecliptical.mainPos))°, Latitude: \(String(format: "%.6f", ecliptical.deviation))°, Distance: \(String(format: "%.6f", ecliptical.distance)) AU")
        //                            print("       Speed - Longitude: \(String(format: "%.6f", ecliptical.mainPosSpeed))°/day, Latitude: \(String(format: "%.6f", ecliptical.deviationSpeed))°/day, Distance: \(String(format: "%.6f", ecliptical.distanceSpeed)) AU/day")
        //                        }
        //                    }
        //
        //                    // Equatorial positions
        //                    if !position.equatorial.isEmpty {
        //                        print("  Equatorial:")
        //                        for (index, equatorial) in position.equatorial.enumerated() {
        //                            print("    [\(index)] RA: \(String(format: "%.6f", equatorial.mainPos))°, Declination: \(String(format: "%.6f", equatorial.deviation))°, Distance: \(String(format: "%.6f", equatorial.distance)) AU")
        //                            print("       Speed - RA: \(String(format: "%.6f", equatorial.mainPosSpeed))°/day, Declination: \(String(format: "%.6f", equatorial.deviationSpeed))°/day, Distance: \(String(format: "%.6f", equatorial.distanceSpeed)) AU/day")
        //                        }
        //                    }
        //
        //                    // Horizontal positions
        //                    if !position.horizontal.isEmpty {
        //                        print("  Horizontal:")
        //                        for (index, horizontal) in position.horizontal.enumerated() {
        //                            print("    [\(index)] Azimuth: \(String(format: "%.6f", horizontal.azimuth))°, Altitude: \(String(format: "%.6f", horizontal.altitude))°")
        //                        }
        //                    }
        //                }
        //                print("\n=== End of Factors and Positions ===\n")
        //
        //                // Get Sun's longitude
        //                if let sunPosition = fullChart.Coordinates[.sun],
        //                   let sunEcliptical = sunPosition.ecliptical.first {
        //                    sunLongitude = sunEcliptical.mainPos
        //                }
        //            }
        //        }
    }
    
    //    private func addItem() {
    //        withAnimation {
    //            let newItem = Item(timestamp: Date())
    //            modelContext.insert(newItem)
    //        }
    //    }
    //
    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            for index in offsets {
    //                modelContext.delete(items[index])
    //            }
    //        }
    //    }
    //}
    //
    //#Preview {
    //    ContentView(seWrapper: SEWrapper())
    //        .modelContainer(for: Item.self, inMemory: true)
    //}
}
