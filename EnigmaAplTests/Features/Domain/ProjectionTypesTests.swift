//
//  ProjectionTypesTests.swift
//  EnigmaAplTests
//
//  Created on 01/01/2026.
//

import Testing
@testable import EnigmaApl

struct ProjectionTypesTests {
    
    // MARK: - Enum Cases Tests
    
    @Test("ProjectionTypes: allCases contains all projection types")
    func testAllCasesCompleteness() {
        let allCases = ProjectionTypes.allCases
        #expect(allCases.contains(.twoDimensional))
        #expect(allCases.contains(.obliqueLongitude))
        #expect(allCases.count == 2) // Total number of projection types
    }
    
    // MARK: - RB Key Tests
    
    @Test("ProjectionTypes: rbKey - twoDimensional")
    func testRbKeyTwoDimensional() {
        #expect(ProjectionTypes.twoDimensional.rbKey == "enum.projectiontype.twodimensional")
    }
    
    @Test("ProjectionTypes: rbKey - obliqueLongitude")
    func testRbKeyObliqueLongitude() {
        #expect(ProjectionTypes.obliqueLongitude.rbKey == "enum.projectiontype.obliquelongitude")
    }
    
    @Test("ProjectionTypes: rbKey - all projection types have localization keys")
    func testRbKeyAllProjectionTypes() {
        for projectionType in ProjectionTypes.allCases {
            let key = projectionType.rbKey
            #expect(!key.isEmpty)
            #expect(key.hasPrefix("enum.projectiontype."))
        }
    }
    
    // MARK: - FromIndex Tests
    
    @Test("ProjectionTypes: fromIndex - valid indices")
    func testFromIndexValid() {
        for projectionType in ProjectionTypes.allCases {
            let found = ProjectionTypes.fromIndex(projectionType.rawValue)
            #expect(found == projectionType)
        }
    }
    
    @Test("ProjectionTypes: fromIndex - first index")
    func testFromIndexFirst() {
        let projectionType = ProjectionTypes.fromIndex(0)
        #expect(projectionType == ProjectionTypes.twoDimensional)
    }
    
    @Test("ProjectionTypes: fromIndex - last index")
    func testFromIndexLast() {
        let projectionType = ProjectionTypes.fromIndex(1)
        #expect(projectionType == ProjectionTypes.obliqueLongitude)
    }
    
    @Test("ProjectionTypes: fromIndex - specific indices")
    func testFromIndexSpecific() {
        #expect(ProjectionTypes.fromIndex(0) == ProjectionTypes.twoDimensional)
        #expect(ProjectionTypes.fromIndex(1) == ProjectionTypes.obliqueLongitude)
    }
    
    @Test("ProjectionTypes: fromIndex - invalid indices")
    func testFromIndexInvalid() {
        #expect(ProjectionTypes.fromIndex(-1) == nil)
        #expect(ProjectionTypes.fromIndex(2) == nil)
        #expect(ProjectionTypes.fromIndex(100) == nil)
    }
    
    // MARK: - Raw Value Tests
    
    @Test("ProjectionTypes: raw values match expected values")
    func testRawValuesMatchExpected() {
        #expect(ProjectionTypes.twoDimensional.rawValue == 0)
        #expect(ProjectionTypes.obliqueLongitude.rawValue == 1)
    }
    
    @Test("ProjectionTypes: raw values are unique")
    func testRawValuesUnique() {
        var rawValues: Set<Int> = []
        for projectionType in ProjectionTypes.allCases {
            let rawValue = projectionType.rawValue
            #expect(!rawValues.contains(rawValue), "Duplicate raw value \(rawValue) found")
            rawValues.insert(rawValue)
        }
    }
    
    @Test("ProjectionTypes: raw values are sequential")
    func testRawValuesSequential() {
        let allCases = Array(ProjectionTypes.allCases.sorted(by: { $0.rawValue < $1.rawValue }))
        for (index, projectionType) in allCases.enumerated() {
            #expect(projectionType.rawValue == index)
        }
    }
    
    // MARK: - Comprehensive Tests
    
    @Test("ProjectionTypes: all projection types have rbKey")
    func testAllProjectionTypesHaveRbKey() {
        for projectionType in ProjectionTypes.allCases {
            let key = projectionType.rbKey
            #expect(!key.isEmpty)
        }
    }
    
    @Test("ProjectionTypes: enum is CaseIterable")
    func testCaseIterable() {
        let allCases = ProjectionTypes.allCases
        #expect(allCases.count == 2)
        
        // Verify we can iterate
        var count = 0
        for _ in allCases {
            count += 1
        }
        #expect(count == 2)
    }
    
    @Test("ProjectionTypes: enum is Int-backed")
    func testIntBacked() {
        // Test that we can create from raw value
        if let twoDimensional = ProjectionTypes(rawValue: 0) {
            #expect(twoDimensional == .twoDimensional)
        } else {
            Issue.record("Failed to create ProjectionTypes from rawValue 0")
        }
        
        if let obliqueLongitude = ProjectionTypes(rawValue: 1) {
            #expect(obliqueLongitude == .obliqueLongitude)
        } else {
            Issue.record("Failed to create ProjectionTypes from rawValue 1")
        }
    }
    
    @Test("ProjectionTypes: all projection types exist")
    func testAllProjectionTypesExist() {
        #expect(ProjectionTypes.allCases.contains(.twoDimensional))
        #expect(ProjectionTypes.allCases.contains(.obliqueLongitude))
    }
    
    @Test("ProjectionTypes: rbKey format is consistent")
    func testRbKeyFormatConsistent() {
        for projectionType in ProjectionTypes.allCases {
            let key = projectionType.rbKey
            // All keys should start with "enum.projectiontype."
            #expect(key.hasPrefix("enum.projectiontype."))
            // Key should not be empty after prefix
            let suffix = String(key.dropFirst("enum.projectiontype.".count))
            #expect(!suffix.isEmpty)
        }
    }
    
    @Test("ProjectionTypes: fromIndex matches rawValue")
    func testFromIndexMatchesRawValue() {
        for projectionType in ProjectionTypes.allCases {
            let found = ProjectionTypes.fromIndex(projectionType.rawValue)
            #expect(found == projectionType, "fromIndex(\(projectionType.rawValue)) should return \(projectionType)")
        }
    }
    
    @Test("ProjectionTypes: projection types are distinct")
    func testProjectionTypesAreDistinct() {
        #expect(ProjectionTypes.twoDimensional != ProjectionTypes.obliqueLongitude)
        
        #expect(ProjectionTypes.twoDimensional.rawValue != ProjectionTypes.obliqueLongitude.rawValue)
    }
    
    // MARK: - Specific Use Case Tests
    
    @Test("ProjectionTypes: twoDimensional is default projection")
    func testTwoDimensionalIsDefault() {
        #expect(ProjectionTypes.twoDimensional.rawValue == 0)
        #expect(ProjectionTypes.twoDimensional.rbKey == "enum.projectiontype.twodimensional")
    }
    
    @Test("ProjectionTypes: obliqueLongitude is alternative projection")
    func testObliqueLongitudeIsAlternative() {
        #expect(ProjectionTypes.obliqueLongitude.rawValue == 1)
        #expect(ProjectionTypes.obliqueLongitude.rbKey == "enum.projectiontype.obliquelongitude")
    }
}

