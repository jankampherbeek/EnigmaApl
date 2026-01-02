//
//  AyanamshasTests.swift
//  EnigmaAplTests
//
//  Created on 24/12/2025.
//

import Testing
@testable import EnigmaApl

struct AyanamshasTests {
    
    // MARK: - Enum Cases Tests
    
    @Test("Ayanamshas: allCases contains all ayanamshas")
    func testAllCasesCompleteness() {
        let allCases = Ayanamshas.allCases
        #expect(allCases.contains(.tropical))
        #expect(allCases.contains(.fagan))
        #expect(allCases.contains(.lahiri))
        #expect(allCases.contains(.galacticCtrOCap))
        #expect(allCases.count == 41) // Total number of ayanamshas
    }
    
    // MARK: - SE ID Tests
    
    @Test("Ayanamshas: seId - tropical has special value")
    func testSeIdTropical() {
        #expect(Ayanamshas.tropical.seId == -1)
    }
    
    @Test("Ayanamshas: seId - common ayanamshas")
    func testSeIdCommonAyanamshas() {
        #expect(Ayanamshas.fagan.seId == 0)
        #expect(Ayanamshas.lahiri.seId == 1)
        #expect(Ayanamshas.deLuce.seId == 2)
        #expect(Ayanamshas.raman.seId == 3)
        #expect(Ayanamshas.ushaShashi.seId == 4)
        #expect(Ayanamshas.krishnamurti.seId == 5)
        #expect(Ayanamshas.djwhalKhul.seId == 6)
        #expect(Ayanamshas.yukteshwar.seId == 7)
        #expect(Ayanamshas.bhasin.seId == 8)
    }
    
    @Test("Ayanamshas: seId - Kugler ayanamshas")
    func testSeIdKugler() {
        #expect(Ayanamshas.kugler1.seId == 9)
        #expect(Ayanamshas.kugler2.seId == 10)
        #expect(Ayanamshas.kugler3.seId == 11)
    }
    
    @Test("Ayanamshas: seId - Huber and specialized")
    func testSeIdHuberAndSpecialized() {
        #expect(Ayanamshas.huber.seId == 12)
        #expect(Ayanamshas.etaPiscium.seId == 13)
        #expect(Ayanamshas.aldebaran15Tau.seId == 14)
        #expect(Ayanamshas.hipparchus.seId == 15)
        #expect(Ayanamshas.sassanian.seId == 16)
        #expect(Ayanamshas.galactCtr0Sag.seId == 17)
    }
    
    @Test("Ayanamshas: seId - epoch-based ayanamshas")
    func testSeIdEpochBased() {
        #expect(Ayanamshas.j2000.seId == 18)
        #expect(Ayanamshas.j1900.seId == 19)
        #expect(Ayanamshas.b1950.seId == 20)
    }
    
    @Test("Ayanamshas: seId - Surya Siddhanta ayanamshas")
    func testSeIdSuryaSiddhanta() {
        #expect(Ayanamshas.suryaSiddhanta.seId == 21)
        #expect(Ayanamshas.suryaSiddhantaMeanSun.seId == 22)
    }
    
    @Test("Ayanamshas: seId - Aryabhata ayanamshas")
    func testSeIdAryabhata() {
        #expect(Ayanamshas.aryabhata.seId == 23)
        #expect(Ayanamshas.aryabhataMeanSun.seId == 24)
        #expect(Ayanamshas.aryabhata522.seId == 37)
    }
    
    @Test("Ayanamshas: seId - Surya Siddhanta star-based")
    func testSeIdSuryaSiddhantaStar() {
        #expect(Ayanamshas.ssRevati.seId == 25)
        #expect(Ayanamshas.ssCitra.seId == 26)
    }
    
    @Test("Ayanamshas: seId - True star-based ayanamshas")
    func testSeIdTrueStar() {
        #expect(Ayanamshas.trueCitra.seId == 27)
        #expect(Ayanamshas.trueRevati.seId == 28)
        #expect(Ayanamshas.truePushya.seId == 29)
        #expect(Ayanamshas.trueMula.seId == 35)
    }
    
    @Test("Ayanamshas: seId - Galactic ayanamshas")
    func testSeIdGalactic() {
        #expect(Ayanamshas.galacticCtrBrand.seId == 30)
        #expect(Ayanamshas.galacticEqIau1958.seId == 31)
        #expect(Ayanamshas.galacticEq.seId == 32)
        #expect(Ayanamshas.galacticEqMidMula.seId == 33)
        #expect(Ayanamshas.galacticCtrOCap.seId == 39)
    }
    
    @Test("Ayanamshas: seId - other specialized")
    func testSeIdOtherSpecialized() {
        #expect(Ayanamshas.skydram.seId == 34)
        #expect(Ayanamshas.dhruva.seId == 36)
        #expect(Ayanamshas.britton.seId == 38)
    }
    
    @Test("Ayanamshas: seId - all ayanamshas have valid SE ID")
    func testSeIdAllAyanamshas() {
        for ayanamsha in Ayanamshas.allCases {
            let seId = ayanamsha.seId
            // Tropical has -1, all others should be >= 0
            if ayanamsha == .tropical {
                #expect(seId == -1)
            } else {
                #expect(seId >= 0)
                #expect(seId <= 39) // Maximum SE ID is 39
            }
        }
    }
    
    // MARK: - RB Key Tests
    
    @Test("Ayanamshas: rbKey - tropical")
    func testRbKeyTropical() {
        #expect(Ayanamshas.tropical.rbKey == "enum.ayanamsha.tropical")
    }
    
    @Test("Ayanamshas: rbKey - common ayanamshas")
    func testRbKeyCommonAyanamshas() {
        #expect(Ayanamshas.fagan.rbKey == "enum.ayanamsha.fagan")
        #expect(Ayanamshas.lahiri.rbKey == "enum.ayanamsha.lahiri")
        #expect(Ayanamshas.deLuce.rbKey == "enum.ayanamsha.deluce")
        #expect(Ayanamshas.raman.rbKey == "enum.ayanamsha.raman")
        #expect(Ayanamshas.ushaShashi.rbKey == "enum.ayanamsha.ushashashi")
        #expect(Ayanamshas.krishnamurti.rbKey == "enum.ayanamsha.krishnamurti")
    }
    
    @Test("Ayanamshas: rbKey - Kugler ayanamshas")
    func testRbKeyKugler() {
        #expect(Ayanamshas.kugler1.rbKey == "enum.ayanamsha.kugler1")
        #expect(Ayanamshas.kugler2.rbKey == "enum.ayanamsha.kugler2")
        #expect(Ayanamshas.kugler3.rbKey == "enum.ayanamsha.kugler3")
    }
    
    @Test("Ayanamshas: rbKey - epoch-based ayanamshas")
    func testRbKeyEpochBased() {
        #expect(Ayanamshas.j2000.rbKey == "enum.ayanamsha.j2000")
        #expect(Ayanamshas.j1900.rbKey == "enum.ayanamsha.j1900")
        #expect(Ayanamshas.b1950.rbKey == "enum.ayanamsha.b1950")
    }
    
    @Test("Ayanamshas: rbKey - Surya Siddhanta")
    func testRbKeySuryaSiddhanta() {
        #expect(Ayanamshas.suryaSiddhanta.rbKey == "enum.ayanamsha.suryasiddhanta")
        #expect(Ayanamshas.suryaSiddhantaMeanSun.rbKey == "enum.ayanamsha.suryasiddhantameansun")
    }
    
    @Test("Ayanamshas: rbKey - Aryabhata")
    func testRbKeyAryabhata() {
        #expect(Ayanamshas.aryabhata.rbKey == "enum.ayanamsha.aryabhata")
        #expect(Ayanamshas.aryabhataMeanSun.rbKey == "enum.ayanamsha.aryabhatameansun")
        #expect(Ayanamshas.aryabhata522.rbKey == "enum.ayanamsha.aryabhata522")
    }
    
    @Test("Ayanamshas: rbKey - true star-based")
    func testRbKeyTrueStar() {
        #expect(Ayanamshas.trueCitra.rbKey == "enum.ayanamsha.truecitrapaksha")
        #expect(Ayanamshas.trueRevati.rbKey == "enum.ayanamsha.truerevati")
        #expect(Ayanamshas.truePushya.rbKey == "enum.ayanamsha.truepushya")
        #expect(Ayanamshas.trueMula.rbKey == "enum.ayanamsha.truemula")
    }
    
    @Test("Ayanamshas: rbKey - galactic")
    func testRbKeyGalactic() {
        #expect(Ayanamshas.galacticCtrBrand.rbKey == "enum.ayanamsha.galcentbrand")
        #expect(Ayanamshas.galacticEqIau1958.rbKey == "enum.ayanamsha.galcentiau1958")
        #expect(Ayanamshas.galacticEq.rbKey == "enum.ayanamsha.galequator")
        #expect(Ayanamshas.galacticEqMidMula.rbKey == "enum.ayanamsha.galequatormidmula")
        #expect(Ayanamshas.galactCtr0Sag.rbKey == "enum.ayanamsha.galcent0sag")
        #expect(Ayanamshas.galacticCtrOCap.rbKey == "enum.ayanamsha.galcent0cap")
    }
    
    @Test("Ayanamshas: rbKey - all ayanamshas have localization keys")
    func testRbKeyAllAyanamshas() {
        for ayanamsha in Ayanamshas.allCases {
            let key = ayanamsha.rbKey
            #expect(!key.isEmpty)
            #expect(key.hasPrefix("enum.ayanamsha."))
        }
    }
    
    // MARK: - FromIndex Tests
    
    @Test("Ayanamshas: fromIndex - valid indices")
    func testFromIndexValid() {
        for ayanamsha in Ayanamshas.allCases {
            let found = Ayanamshas.fromIndex(ayanamsha.rawValue)
            #expect(found == ayanamsha)
        }
    }
    
    @Test("Ayanamshas: fromIndex - first index")
    func testFromIndexFirst() {
        let ayanamsha = Ayanamshas.fromIndex(0)
        #expect(ayanamsha == Ayanamshas.tropical)
    }
    
    @Test("Ayanamshas: fromIndex - last index")
    func testFromIndexLast() {
        let ayanamsha = Ayanamshas.fromIndex(40)
        #expect(ayanamsha == .galacticCtrOCap)
    }
    
    @Test("Ayanamshas: fromIndex - specific indices")
    func testFromIndexSpecific() {
        #expect(Ayanamshas.fromIndex(0) == Ayanamshas.tropical)
        #expect(Ayanamshas.fromIndex(1) == .fagan)
        #expect(Ayanamshas.fromIndex(2) == .lahiri)
        #expect(Ayanamshas.fromIndex(18) == .galactCtr0Sag)
        #expect(Ayanamshas.fromIndex(40) == .galacticCtrOCap)
    }
    
    @Test("Ayanamshas: fromIndex - invalid indices")
    func testFromIndexInvalid() {
        #expect(Ayanamshas.fromIndex(-1) == nil)
        #expect(Ayanamshas.fromIndex(41) == nil)
        #expect(Ayanamshas.fromIndex(100) == nil)
    }
    
    // MARK: - Raw Value Tests
    
    @Test("Ayanamshas: raw values match expected values")
    func testRawValuesMatchExpected() {
        #expect(Ayanamshas.tropical.rawValue == 0)
        #expect(Ayanamshas.fagan.rawValue == 1)
        #expect(Ayanamshas.lahiri.rawValue == 2)
        #expect(Ayanamshas.deLuce.rawValue == 3)
        #expect(Ayanamshas.raman.rawValue == 4)
        #expect(Ayanamshas.ushaShashi.rawValue == 5)
        #expect(Ayanamshas.krishnamurti.rawValue == 6)
        #expect(Ayanamshas.djwhalKhul.rawValue == 7)
        #expect(Ayanamshas.yukteshwar.rawValue == 8)
        #expect(Ayanamshas.bhasin.rawValue == 9)
        #expect(Ayanamshas.kugler1.rawValue == 10)
        #expect(Ayanamshas.kugler2.rawValue == 11)
        #expect(Ayanamshas.kugler3.rawValue == 12)
        #expect(Ayanamshas.huber.rawValue == 13)
        #expect(Ayanamshas.etaPiscium.rawValue == 14)
        #expect(Ayanamshas.aldebaran15Tau.rawValue == 15)
        #expect(Ayanamshas.hipparchus.rawValue == 16)
        #expect(Ayanamshas.sassanian.rawValue == 17)
        #expect(Ayanamshas.galactCtr0Sag.rawValue == 18)
        #expect(Ayanamshas.j2000.rawValue == 19)
        #expect(Ayanamshas.j1900.rawValue == 20)
        #expect(Ayanamshas.b1950.rawValue == 21)
        #expect(Ayanamshas.suryaSiddhanta.rawValue == 22)
        #expect(Ayanamshas.suryaSiddhantaMeanSun.rawValue == 23)
        #expect(Ayanamshas.aryabhata.rawValue == 24)
        #expect(Ayanamshas.aryabhataMeanSun.rawValue == 25)
        #expect(Ayanamshas.ssRevati.rawValue == 26)
        #expect(Ayanamshas.ssCitra.rawValue == 27)
        #expect(Ayanamshas.trueCitra.rawValue == 28)
        #expect(Ayanamshas.trueRevati.rawValue == 29)
        #expect(Ayanamshas.truePushya.rawValue == 30)
        #expect(Ayanamshas.galacticCtrBrand.rawValue == 31)
        #expect(Ayanamshas.galacticEqIau1958.rawValue == 32)
        #expect(Ayanamshas.galacticEq.rawValue == 33)
        #expect(Ayanamshas.galacticEqMidMula.rawValue == 34)
        #expect(Ayanamshas.skydram.rawValue == 35)
        #expect(Ayanamshas.trueMula.rawValue == 36)
        #expect(Ayanamshas.dhruva.rawValue == 37)
        #expect(Ayanamshas.aryabhata522.rawValue == 38)
        #expect(Ayanamshas.britton.rawValue == 39)
        #expect(Ayanamshas.galacticCtrOCap.rawValue == 40)
    }
    
    @Test("Ayanamshas: raw values are unique")
    func testRawValuesUnique() {
        var rawValues: Set<Int> = []
        for ayanamsha in Ayanamshas.allCases {
            let rawValue = ayanamsha.rawValue
            #expect(!rawValues.contains(rawValue), "Duplicate raw value \(rawValue) found")
            rawValues.insert(rawValue)
        }
    }
    
    @Test("Ayanamshas: raw values are sequential")
    func testRawValuesSequential() {
        let allCases = Array(Ayanamshas.allCases.sorted(by: { $0.rawValue < $1.rawValue }))
        for (index, ayanamsha) in allCases.enumerated() {
            #expect(ayanamsha.rawValue == index)
        }
    }
    
    // MARK: - Comprehensive Tests
    
    @Test("Ayanamshas: all ayanamshas have SE ID")
    func testAllAyanamshasHaveSeId() {
        for ayanamsha in Ayanamshas.allCases {
            let seId = ayanamsha.seId
            // Tropical has -1, all others should be >= 0 and <= 39
            if ayanamsha == .tropical {
                #expect(seId == -1)
            } else {
                #expect(seId >= 0)
                #expect(seId <= 39)
            }
        }
    }
    
    @Test("Ayanamshas: all ayanamshas have rbKey")
    func testAllAyanamshasHaveRbKey() {
        for ayanamsha in Ayanamshas.allCases {
            let key = ayanamsha.rbKey
            #expect(!key.isEmpty)
        }
    }
    
    @Test("Ayanamshas: enum is CaseIterable")
    func testCaseIterable() {
        let allCases = Ayanamshas.allCases
        #expect(allCases.count == 41)
        
        // Verify we can iterate
        var count = 0
        for _ in allCases {
            count += 1
        }
        #expect(count == 41)
    }
    
    @Test("Ayanamshas: enum is Int-backed")
    func testIntBacked() {
        // Test that we can create from raw value
        if let tropical = Ayanamshas(rawValue: 0) {
            #expect(tropical == .tropical)
        } else {
            Issue.record("Failed to create Ayanamshas from rawValue 0")
        }
        
        if let fagan = Ayanamshas(rawValue: 1) {
            #expect(fagan == .fagan)
        } else {
            Issue.record("Failed to create Ayanamshas from rawValue 1")
        }
        
        if let galacticCtrOCap = Ayanamshas(rawValue: 40) {
            #expect(galacticCtrOCap == .galacticCtrOCap)
        } else {
            Issue.record("Failed to create Ayanamshas from rawValue 40")
        }
    }
    
    @Test("Ayanamshas: popular ayanamshas exist")
    func testPopularAyanamshas() {
        // Test the most commonly used ayanamshas
        #expect(Ayanamshas.allCases.contains(.fagan))
        #expect(Ayanamshas.allCases.contains(.lahiri))
        #expect(Ayanamshas.allCases.contains(.raman))
        #expect(Ayanamshas.allCases.contains(.krishnamurti))
        #expect(Ayanamshas.allCases.contains(.j2000))
    }
    
    @Test("Ayanamshas: SE ID values are correct for Swiss Ephemeris")
    func testSeIdValuesCorrect() {
        // Verify that SE IDs match the expected Swiss Ephemeris values
        // Tropical should be -1 (not used in SE, as it's the base zodiac)
        #expect(Ayanamshas.tropical.seId == -1)
        
        // Fagan (0) is the default in many systems
        #expect(Ayanamshas.fagan.seId == 0)
        
        // Lahiri (1) is commonly used in India
        #expect(Ayanamshas.lahiri.seId == 1)
        
        // Verify the last one
        #expect(Ayanamshas.galacticCtrOCap.seId == 39)
    }
    
    @Test("Ayanamshas: rbKey format is consistent")
    func testRbKeyFormatConsistent() {
        for ayanamsha in Ayanamshas.allCases {
            let key = ayanamsha.rbKey
            // All keys should start with "enum.ayanamsha."
            #expect(key.hasPrefix("enum.ayanamsha."))
            // Key should not be empty after prefix
            let suffix = String(key.dropFirst("enum.ayanamsha.".count))
            #expect(!suffix.isEmpty)
        }
    }
    
    @Test("Ayanamshas: fromIndex matches rawValue")
    func testFromIndexMatchesRawValue() {
        for ayanamsha in Ayanamshas.allCases {
            let found = Ayanamshas.fromIndex(ayanamsha.rawValue)
            #expect(found == ayanamsha, "fromIndex(\(ayanamsha.rawValue)) should return \(ayanamsha)")
        }
    }
}

