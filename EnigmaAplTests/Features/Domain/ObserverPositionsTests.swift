//
//  ObserverPositionsTests.swift
//  EnigmaAplTests
//
//  Created on 01/01/2025.
//

import Testing
@testable import EnigmaApl

struct ObserverPositionsTests {
    
    // MARK: - Enum Cases Tests
    
    @Test("ObserverPositions: allCases contains all observer positions")
    func testAllCasesCompleteness() {
        let allCases = ObserverPositions.allCases
        #expect(allCases.contains(.geoCentric))
        #expect(allCases.contains(.topoCentric))
        #expect(allCases.contains(.helioCentric))
        #expect(allCases.count == 3) // Total number of observer positions
    }
    
    // MARK: - RB Key Tests
    
    @Test("ObserverPositions: rbKey - geocentric")
    func testRbKeyGeocentric() {
        #expect(ObserverPositions.geoCentric.rbKey == "enum.observerpos.geocentric")
    }
    
    @Test("ObserverPositions: rbKey - topocentric")
    func testRbKeyTopocentric() {
        #expect(ObserverPositions.topoCentric.rbKey == "enum.observerpos.topocentric")
    }
    
    @Test("ObserverPositions: rbKey - heliocentric")
    func testRbKeyHeliocentric() {
        #expect(ObserverPositions.helioCentric.rbKey == "enum.observerpos.heliocentric")
    }
    
    @Test("ObserverPositions: rbKey - all positions have localization keys")
    func testRbKeyAllPositions() {
        for position in ObserverPositions.allCases {
            let key = position.rbKey
            #expect(!key.isEmpty)
            #expect(key.hasPrefix("enum.observerpos."))
        }
    }
    
    // MARK: - FromIndex Tests
    
    @Test("ObserverPositions: fromIndex - valid indices")
    func testFromIndexValid() {
        for position in ObserverPositions.allCases {
            let found = ObserverPositions.fromIndex(position.rawValue)
            #expect(found == position)
        }
    }
    
    @Test("ObserverPositions: fromIndex - first index")
    func testFromIndexFirst() {
        let position = ObserverPositions.fromIndex(0)
        #expect(position == ObserverPositions.geoCentric)
    }
    
    @Test("ObserverPositions: fromIndex - middle index")
    func testFromIndexMiddle() {
        let position = ObserverPositions.fromIndex(1)
        #expect(position == ObserverPositions.topoCentric)
    }
    
    @Test("ObserverPositions: fromIndex - last index")
    func testFromIndexLast() {
        let position = ObserverPositions.fromIndex(2)
        #expect(position == ObserverPositions.helioCentric)
    }
    
    @Test("ObserverPositions: fromIndex - specific indices")
    func testFromIndexSpecific() {
        #expect(ObserverPositions.fromIndex(0) == ObserverPositions.geoCentric)
        #expect(ObserverPositions.fromIndex(1) == ObserverPositions.topoCentric)
        #expect(ObserverPositions.fromIndex(2) == ObserverPositions.helioCentric)
    }
    
    @Test("ObserverPositions: fromIndex - invalid indices")
    func testFromIndexInvalid() {
        #expect(ObserverPositions.fromIndex(-1) == nil)
        #expect(ObserverPositions.fromIndex(3) == nil)
        #expect(ObserverPositions.fromIndex(100) == nil)
    }
    
    // MARK: - Raw Value Tests
    
    @Test("ObserverPositions: raw values match expected values")
    func testRawValuesMatchExpected() {
        #expect(ObserverPositions.geoCentric.rawValue == 0)
        #expect(ObserverPositions.topoCentric.rawValue == 1)
        #expect(ObserverPositions.helioCentric.rawValue == 2)
    }
    
    @Test("ObserverPositions: raw values are unique")
    func testRawValuesUnique() {
        var rawValues: Set<Int> = []
        for position in ObserverPositions.allCases {
            let rawValue = position.rawValue
            #expect(!rawValues.contains(rawValue), "Duplicate raw value \(rawValue) found")
            rawValues.insert(rawValue)
        }
    }
    
    @Test("ObserverPositions: raw values are sequential")
    func testRawValuesSequential() {
        let allCases = Array(ObserverPositions.allCases.sorted(by: { $0.rawValue < $1.rawValue }))
        for (index, position) in allCases.enumerated() {
            #expect(position.rawValue == index)
        }
    }
    
    // MARK: - Comprehensive Tests
    
    @Test("ObserverPositions: all positions have rbKey")
    func testAllPositionsHaveRbKey() {
        for position in ObserverPositions.allCases {
            let key = position.rbKey
            #expect(!key.isEmpty)
        }
    }
    
    @Test("ObserverPositions: enum is CaseIterable")
    func testCaseIterable() {
        let allCases = ObserverPositions.allCases
        #expect(allCases.count == 3)
        
        // Verify we can iterate
        var count = 0
        for _ in allCases {
            count += 1
        }
        #expect(count == 3)
    }
    
    @Test("ObserverPositions: enum is Int-backed")
    func testIntBacked() {
        // Test that we can create from raw value
        if let geoCentric = ObserverPositions(rawValue: 0) {
            #expect(geoCentric == .geoCentric)
        } else {
            Issue.record("Failed to create ObserverPositions from rawValue 0")
        }
        
        if let topoCentric = ObserverPositions(rawValue: 1) {
            #expect(topoCentric == .topoCentric)
        } else {
            Issue.record("Failed to create ObserverPositions from rawValue 1")
        }
        
        if let helioCentric = ObserverPositions(rawValue: 2) {
            #expect(helioCentric == .helioCentric)
        } else {
            Issue.record("Failed to create ObserverPositions from rawValue 2")
        }
    }
    
    @Test("ObserverPositions: all observer positions exist")
    func testAllObserverPositionsExist() {
        #expect(ObserverPositions.allCases.contains(.geoCentric))
        #expect(ObserverPositions.allCases.contains(.topoCentric))
        #expect(ObserverPositions.allCases.contains(.helioCentric))
    }
    
    @Test("ObserverPositions: rbKey format is consistent")
    func testRbKeyFormatConsistent() {
        for position in ObserverPositions.allCases {
            let key = position.rbKey
            // All keys should start with "enum.observerpos."
            #expect(key.hasPrefix("enum.observerpos."))
            // Key should not be empty after prefix
            let suffix = String(key.dropFirst("enum.observerpos.".count))
            #expect(!suffix.isEmpty)
        }
    }
    
    @Test("ObserverPositions: fromIndex matches rawValue")
    func testFromIndexMatchesRawValue() {
        for position in ObserverPositions.allCases {
            let found = ObserverPositions.fromIndex(position.rawValue)
            #expect(found == position, "fromIndex(\(position.rawValue)) should return \(position)")
        }
    }
    
    @Test("ObserverPositions: positions are distinct")
    func testPositionsAreDistinct() {
        #expect(ObserverPositions.geoCentric != ObserverPositions.topoCentric)
        #expect(ObserverPositions.geoCentric != ObserverPositions.helioCentric)
        #expect(ObserverPositions.topoCentric != ObserverPositions.helioCentric)
        
        #expect(ObserverPositions.geoCentric.rawValue != ObserverPositions.topoCentric.rawValue)
        #expect(ObserverPositions.geoCentric.rawValue != ObserverPositions.helioCentric.rawValue)
        #expect(ObserverPositions.topoCentric.rawValue != ObserverPositions.helioCentric.rawValue)
    }
}

