//
//  HouseSystemsTests.swift
//  EnigmaAplTests
//
//  Created on 24/12/2025.
//

import Testing
@testable import EnigmaApl

struct HouseSystemsTests {
    
    // MARK: - Enum Cases Tests
    
    @Test("HouseSystems: all cases are accessible")
    func testAllHouseSystemsCases() {
        // Test that all major cases exist
        #expect(HouseSystems.noHouses != nil)
        #expect(HouseSystems.placidus != nil)
        #expect(HouseSystems.koch != nil)
        #expect(HouseSystems.porphyri != nil)
        #expect(HouseSystems.regiomontanus != nil)
        #expect(HouseSystems.campanus != nil)
        #expect(HouseSystems.alcabitius != nil)
        #expect(HouseSystems.topoCentric != nil)
        #expect(HouseSystems.krusinski != nil)
        #expect(HouseSystems.apc != nil)
        #expect(HouseSystems.morin != nil)
        #expect(HouseSystems.wholeSign != nil)
    }
    
    @Test("HouseSystems: allCases contains all house systems")
    func testAllCasesCompleteness() {
        let allCases = HouseSystems.allCases
        #expect(allCases.contains(.noHouses))
        #expect(allCases.contains(.placidus))
        #expect(allCases.contains(.koch))
        #expect(allCases.contains(.wholeSign))
        #expect(allCases.contains(.sripati))
        #expect(allCases.count == 25) // Total number of house systems
    }
    
    // MARK: - SE ID Tests
    
    @Test("HouseSystems: seId - common house systems")
    func testSeIdCommonHouseSystems() {
        #expect(HouseSystems.noHouses.seId == "W")
        #expect(HouseSystems.placidus.seId == "P")
        #expect(HouseSystems.koch.seId == "K")
        #expect(HouseSystems.porphyri.seId == "O")
        #expect(HouseSystems.regiomontanus.seId == "R")
        #expect(HouseSystems.campanus.seId == "C")
        #expect(HouseSystems.alcabitius.seId == "B")
        #expect(HouseSystems.topoCentric.seId == "T")
        #expect(HouseSystems.krusinski.seId == "U")
        #expect(HouseSystems.apc.seId == "Y")
        #expect(HouseSystems.morin.seId == "M")
    }
    
    @Test("HouseSystems: seId - whole sign and equal house systems")
    func testSeIdWholeSignAndEqual() {
        #expect(HouseSystems.wholeSign.seId == "W")
        #expect(HouseSystems.equalAsc.seId == "A")
        #expect(HouseSystems.equalMc.seId == "D")
        #expect(HouseSystems.equalAries.seId == "N")
    }
    
    @Test("HouseSystems: seId - specialized house systems")
    func testSeIdSpecialized() {
        #expect(HouseSystems.vehlow.seId == "V")
        #expect(HouseSystems.axial.seId == "X")
        #expect(HouseSystems.horizon.seId == "H")
        #expect(HouseSystems.carter.seId == "F")
        #expect(HouseSystems.gauquelin.seId == "G")
    }
    
    @Test("HouseSystems: seId - sunshine and pullen systems")
    func testSeIdSunshineAndPullen() {
        #expect(HouseSystems.sunShine.seId == "i")
        #expect(HouseSystems.sunShineTreindl.seId == "I")
        #expect(HouseSystems.pullenSd.seId == "L")
        #expect(HouseSystems.pullenSr.seId == "Q")
        #expect(HouseSystems.sripati.seId == "S")
    }
    
    @Test("HouseSystems: seId - all systems have single character")
    func testSeIdSingleCharacter() {
        for houseSystem in HouseSystems.allCases {
            let seId = houseSystem.seId
            #expect(seId.isASCII)
            #expect(seId.unicodeScalars.count == 1)
        }
    }
    
    @Test("HouseSystems: seId - noHouses and wholeSign share same SE ID")
    func testSeIdNoHousesAndWholeSignShare() {
        // Both noHouses and wholeSign use "W" - this is intentional
        #expect(HouseSystems.noHouses.seId == HouseSystems.wholeSign.seId)
        #expect(HouseSystems.noHouses.seId == "W")
        #expect(HouseSystems.wholeSign.seId == "W")
    }
    
    // MARK: - LocalizedName Tests
    
    @Test("HouseSystems: localizedName - common house systems")
    func testLocalizedNameCommon() {
        #expect(HouseSystems.noHouses.localizedName == "enum.housesystem.nohouses")
        #expect(HouseSystems.placidus.localizedName == "enum.housesystem.placidus")
        #expect(HouseSystems.koch.localizedName == "enum.housesystem.koch")
        #expect(HouseSystems.porphyri.localizedName == "enum.housesystem.porphyri")
        #expect(HouseSystems.regiomontanus.localizedName == "enum.housesystem.regiomontanus")
        #expect(HouseSystems.campanus.localizedName == "enum.housesystem.campanus")
        #expect(HouseSystems.alcabitius.localizedName == "enum.housesystem.alcabitius")
    }
    
    @Test("HouseSystems: localizedName - topocentric and specialized")
    func testLocalizedNameTopocentricAndSpecialized() {
        #expect(HouseSystems.topoCentric.localizedName == "enum.housesystem.topocentric")
        #expect(HouseSystems.krusinski.localizedName == "enum.housesystem.krusinski")
        #expect(HouseSystems.apc.localizedName == "enum.housesystem.apc")
        #expect(HouseSystems.morin.localizedName == "enum.housesystem.morin")
    }
    
    @Test("HouseSystems: localizedName - whole sign and equal house systems")
    func testLocalizedNameWholeSignAndEqual() {
        #expect(HouseSystems.wholeSign.localizedName == "enum.housesystem.whole_sign")
        #expect(HouseSystems.equalAsc.localizedName == "enum.housesystem.equal_from_ascendant")
        #expect(HouseSystems.equalMc.localizedName == "enum.housesystem.equal_from_mc")
        #expect(HouseSystems.equalAries.localizedName == "enum.housesystem.equal_from_0_aries")
    }
    
    @Test("HouseSystems: localizedName - vehlow and axial")
    func testLocalizedNameVehlowAndAxial() {
        #expect(HouseSystems.vehlow.localizedName == "enum.housesystem.vehlow")
        #expect(HouseSystems.axial.localizedName == "enum.housesystem.axial_rotation")
        #expect(HouseSystems.horizon.localizedName == "enum.housesystem.horizon")
    }
    
    @Test("HouseSystems: localizedName - carter and gauquelin")
    func testLocalizedNameCarterAndGauquelin() {
        #expect(HouseSystems.carter.localizedName == "enum.housesystem.carter")
        #expect(HouseSystems.gauquelin.localizedName == "enum.housesystem.gauquelin")
    }
    
    @Test("HouseSystems: localizedName - sunshine systems")
    func testLocalizedNameSunshine() {
        #expect(HouseSystems.sunShine.localizedName == "enum.housesystem.sunshine")
        #expect(HouseSystems.sunShineTreindl.localizedName == "enum.housesystem.sunshine_treindl")
    }
    
    @Test("HouseSystems: localizedName - pullen systems")
    func testLocalizedNamePullen() {
        #expect(HouseSystems.pullenSd.localizedName == "enum.housesystem.pullen_sin_diff")
        #expect(HouseSystems.pullenSr.localizedName == "enum.housesys.pullen_sin_ratio")
    }
    
    @Test("HouseSystems: localizedName - sripati")
    func testLocalizedNameSripati() {
        #expect(HouseSystems.sripati.localizedName == "enum.housesys.sripati")
    }
    
    @Test("HouseSystems: localizedName - all systems have localization keys")
    func testLocalizedNameAllSystems() {
        for houseSystem in HouseSystems.allCases {
            let name = houseSystem.localizedName
            #expect(!name.isEmpty)
            #expect(name.hasPrefix("enum.house"))
        }
    }
    
    // MARK: - FromIndex Tests
    
    @Test("HouseSystems: fromIndex - valid indices")
    func testFromIndexValid() {
        let allCases = Array(HouseSystems.allCases)
        for (index, expectedSystem) in allCases.enumerated() {
            let system = HouseSystems.fromIndex(index)
            #expect(system == expectedSystem)
        }
    }
    
    @Test("HouseSystems: fromIndex - first index")
    func testFromIndexFirst() {
        let system = HouseSystems.fromIndex(0)
        #expect(system == HouseSystems.allCases.first)
        #expect(system == .noHouses)
    }
    
    @Test("HouseSystems: fromIndex - last index")
    func testFromIndexLast() {
        let lastIndex = HouseSystems.allCases.count - 1
        let system = HouseSystems.fromIndex(lastIndex)
        #expect(system == HouseSystems.allCases.last)
        #expect(system == .sripati)
    }
    
    @Test("HouseSystems: fromIndex - negative index")
    func testFromIndexNegative() {
        let system = HouseSystems.fromIndex(-1)
        #expect(system == nil)
    }
    
    @Test("HouseSystems: fromIndex - index too large")
    func testFromIndexTooLarge() {
        let tooLargeIndex = HouseSystems.allCases.count
        let system = HouseSystems.fromIndex(tooLargeIndex)
        #expect(system == nil)
    }
    
    @Test("HouseSystems: fromIndex - index at boundary")
    func testFromIndexBoundary() {
        let boundaryIndex = HouseSystems.allCases.count
        let system = HouseSystems.fromIndex(boundaryIndex)
        #expect(system == nil)
        
        let validBoundaryIndex = HouseSystems.allCases.count - 1
        let validSystem = HouseSystems.fromIndex(validBoundaryIndex)
        #expect(validSystem != nil)
        #expect(validSystem == .sripati)
    }
    
    @Test("HouseSystems: fromIndex - specific indices")
    func testFromIndexSpecific() {
        #expect(HouseSystems.fromIndex(0) == .noHouses)
        #expect(HouseSystems.fromIndex(1) == .placidus)
        #expect(HouseSystems.fromIndex(2) == .koch)
        #expect(HouseSystems.fromIndex(11) == .wholeSign)
        #expect(HouseSystems.fromIndex(24) == .sripati)
    }
    
    // MARK: - Raw Value Tests
    
    @Test("HouseSystems: raw values are sequential")
    func testRawValuesSequential() {
        let allCases = Array(HouseSystems.allCases)
        for (index, houseSystem) in allCases.enumerated() {
            #expect(houseSystem.rawValue == index)
        }
    }
    
    @Test("HouseSystems: raw values match expected values")
    func testRawValuesMatchExpected() {
        #expect(HouseSystems.noHouses.rawValue == 0)
        #expect(HouseSystems.placidus.rawValue == 1)
        #expect(HouseSystems.koch.rawValue == 2)
        #expect(HouseSystems.porphyri.rawValue == 3)
        #expect(HouseSystems.regiomontanus.rawValue == 4)
        #expect(HouseSystems.campanus.rawValue == 5)
        #expect(HouseSystems.alcabitius.rawValue == 6)
        #expect(HouseSystems.topoCentric.rawValue == 7)
        #expect(HouseSystems.krusinski.rawValue == 8)
        #expect(HouseSystems.apc.rawValue == 9)
        #expect(HouseSystems.morin.rawValue == 10)
        #expect(HouseSystems.wholeSign.rawValue == 11)
        #expect(HouseSystems.equalAsc.rawValue == 12)
        #expect(HouseSystems.equalMc.rawValue == 13)
        #expect(HouseSystems.equalAries.rawValue == 14)
        #expect(HouseSystems.vehlow.rawValue == 15)
        #expect(HouseSystems.axial.rawValue == 16)
        #expect(HouseSystems.horizon.rawValue == 17)
        #expect(HouseSystems.carter.rawValue == 18)
        #expect(HouseSystems.gauquelin.rawValue == 19)
        #expect(HouseSystems.sunShine.rawValue == 20)
        #expect(HouseSystems.sunShineTreindl.rawValue == 21)
        #expect(HouseSystems.pullenSd.rawValue == 22)
        #expect(HouseSystems.pullenSr.rawValue == 23)
        #expect(HouseSystems.sripati.rawValue == 24)
    }
    
    @Test("HouseSystems: raw values are unique")
    func testRawValuesUnique() {
        var rawValues: Set<Int> = []
        for houseSystem in HouseSystems.allCases {
            let rawValue = houseSystem.rawValue
            #expect(!rawValues.contains(rawValue), "Duplicate raw value \(rawValue) found")
            rawValues.insert(rawValue)
        }
    }
    
    // MARK: - Comprehensive Tests
    
    @Test("HouseSystems: all systems have SE ID")
    func testAllSystemsHaveSeId() {
        for houseSystem in HouseSystems.allCases {
            let seId = houseSystem.seId
            #expect(seId.isASCII)
            #expect(seId.unicodeScalars.count == 1)
        }
    }
    
    @Test("HouseSystems: all systems have localized name")
    func testAllSystemsHaveLocalizedName() {
        for houseSystem in HouseSystems.allCases {
            let name = houseSystem.localizedName
            #expect(!name.isEmpty)
        }
    }
    
    @Test("HouseSystems: enum is CaseIterable")
    func testCaseIterable() {
        let allCases = HouseSystems.allCases
        #expect(allCases.count == 25)
        
        // Verify we can iterate
        var count = 0
        for _ in allCases {
            count += 1
        }
        #expect(count == 25)
    }
    
    @Test("HouseSystems: enum is Int-backed")
    func testIntBacked() {
        // Test that we can create from raw value
        if let noHouses = HouseSystems(rawValue: 0) {
            #expect(noHouses == .noHouses)
        } else {
            Issue.record("Failed to create HouseSystems from rawValue 0")
        }
        
        if let placidus = HouseSystems(rawValue: 1) {
            #expect(placidus == .placidus)
        } else {
            Issue.record("Failed to create HouseSystems from rawValue 1")
        }
        
        if let sripati = HouseSystems(rawValue: 24) {
            #expect(sripati == .sripati)
        } else {
            Issue.record("Failed to create HouseSystems from rawValue 24")
        }
    }
    
    @Test("HouseSystems: SE ID characters are valid ASCII")
    func testSeIdValidASCII() {
        for houseSystem in HouseSystems.allCases {
            let seId = houseSystem.seId
            #expect(seId.isASCII)
            // Verify it's a printable ASCII character
            #expect(seId.asciiValue != nil)
            if let asciiValue = seId.asciiValue {
                #expect(asciiValue >= 32 && asciiValue <= 126) // Printable ASCII range
            }
        }
    }
    
    @Test("HouseSystems: popular house systems exist")
    func testPopularHouseSystems() {
        // Test the most commonly used house systems
        #expect(HouseSystems.allCases.contains(.placidus))
        #expect(HouseSystems.allCases.contains(.koch))
        #expect(HouseSystems.allCases.contains(.wholeSign))
        #expect(HouseSystems.allCases.contains(.equalAsc))
        #expect(HouseSystems.allCases.contains(.regiomontanus))
        #expect(HouseSystems.allCases.contains(.campanus))
    }
    
    @Test("HouseSystems: equal house systems are distinct")
    func testEqualHouseSystemsDistinct() {
        #expect(HouseSystems.equalAsc != HouseSystems.equalMc)
        #expect(HouseSystems.equalAsc != HouseSystems.equalAries)
        #expect(HouseSystems.equalMc != HouseSystems.equalAries)
        
        #expect(HouseSystems.equalAsc.seId != HouseSystems.equalMc.seId)
        #expect(HouseSystems.equalAsc.seId != HouseSystems.equalAries.seId)
        #expect(HouseSystems.equalMc.seId != HouseSystems.equalAries.seId)
    }
    
    @Test("HouseSystems: sunshine systems are distinct")
    func testSunshineSystemsDistinct() {
        #expect(HouseSystems.sunShine != HouseSystems.sunShineTreindl)
        #expect(HouseSystems.sunShine.seId != HouseSystems.sunShineTreindl.seId)
        #expect(HouseSystems.sunShine.seId == "i")
        #expect(HouseSystems.sunShineTreindl.seId == "I")
    }
    
    @Test("HouseSystems: pullen systems are distinct")
    func testPullenSystemsDistinct() {
        #expect(HouseSystems.pullenSd != HouseSystems.pullenSr)
        #expect(HouseSystems.pullenSd.seId != HouseSystems.pullenSr.seId)
        #expect(HouseSystems.pullenSd.seId == "L")
        #expect(HouseSystems.pullenSr.seId == "Q")
    }
}

