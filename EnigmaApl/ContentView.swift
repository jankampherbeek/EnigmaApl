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
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var availableFontFamilies: [String] {
        #if os(macOS)
        return NSFontManager.shared.availableFontFamilies.sorted()
        #else
        return UIFont.familyNames.sorted()
        #endif
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            VStack(alignment: .leading, spacing: 10) {
                Text("The symbol for the Sun is \u{E200}")
                    .font(.custom("EnigmaAstrology2", size: 18))
                    .padding(.bottom, 5)
                
                Text("Available Font Families")
                    .font(.headline)
                    .padding(.bottom, 5)
           
                Text("hello")
                // Alternative explicit approach for debugging:
                // Text(String(localized: "hello"))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(availableFontFamilies, id: \.self) { fontFamily in
                            Text(fontFamily)
                                .font(.system(size: 12))
                                .padding(.vertical, 2)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear {
                // SeTest.PerformTest() // Disabled: SeTest uses SwissEph which is kept for reference only
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
