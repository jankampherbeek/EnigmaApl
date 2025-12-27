//
//  FactorsTests.swift
//  EnigmaAplTests
//
//  Created on 24/12/2025.
//

import Testing
@testable import EnigmaApl

struct FactorsTests {
    
    // MARK: - Enum Cases Tests
    
    @Test("Factors: allCases contains all factors")
    func testAllCasesCompleteness() {
        let allCases = Factors.allCases
        #expect(allCases.contains(.sun))
        #expect(allCases.contains(.moon))
        #expect(allCases.contains(.ascendant))
        #expect(allCases.contains(.mc))
        #expect(allCases.contains(.fortunaSect))
        #expect(allCases.count > 0)
    }
    
    // MARK: - CalculationType Tests
    
    @Test("Factors: calculationType - CommonSe for major planets")
    func testCalculationTypeCommonSeForPlanets() {
        #expect(Factors.sun.calculationType == .CommonSe)
        #expect(Factors.moon.calculationType == .CommonSe)
        #expect(Factors.mercury.calculationType == .CommonSe)
        #expect(Factors.venus.calculationType == .CommonSe)
        #expect(Factors.earth.calculationType == .CommonSe)
        #expect(Factors.mars.calculationType == .CommonSe)
        #expect(Factors.jupiter.calculationType == .CommonSe)
        #expect(Factors.saturn.calculationType == .CommonSe)
        #expect(Factors.uranus.calculationType == .CommonSe)
        #expect(Factors.neptune.calculationType == .CommonSe)
        #expect(Factors.pluto.calculationType == .CommonSe)
    }
    
    @Test("Factors: calculationType - CommonSe for nodes and apogees")
    func testCalculationTypeCommonSeForNodes() {
        #expect(Factors.northNodeMean.calculationType == .CommonSe)
        #expect(Factors.northNodeTrue.calculationType == .CommonSe)
        #expect(Factors.apogeeMean.calculationType == .CommonSe)
        #expect(Factors.apogeeCorrected.calculationType == .CommonSe)
        #expect(Factors.apogeeInterpolated.calculationType == .CommonSe)
        #expect(Factors.perigeeInterpolated.calculationType == .CommonSe)
    }
    
    @Test("Factors: calculationType - CommonSe for asteroids")
    func testCalculationTypeCommonSeForAsteroids() {
        #expect(Factors.chiron.calculationType == .CommonSe)
        #expect(Factors.pholus.calculationType == .CommonSe)
        #expect(Factors.ceres.calculationType == .CommonSe)
        #expect(Factors.pallas.calculationType == .CommonSe)
        #expect(Factors.juno.calculationType == .CommonSe)
        #expect(Factors.vesta.calculationType == .CommonSe)
        #expect(Factors.hygieia.calculationType == .CommonSe)
        #expect(Factors.astraea.calculationType == .CommonSe)
    }
    
    @Test("Factors: calculationType - CommonSe for Uranian planets")
    func testCalculationTypeCommonSeForUranian() {
        #expect(Factors.cupidoUra.calculationType == .CommonSe)
        #expect(Factors.hadesUra.calculationType == .CommonSe)
        #expect(Factors.zeusUra.calculationType == .CommonSe)
        #expect(Factors.kronosUra.calculationType == .CommonSe)
        #expect(Factors.apollonUra.calculationType == .CommonSe)
        #expect(Factors.admetosUra.calculationType == .CommonSe)
        #expect(Factors.vulcanusUra.calculationType == .CommonSe)
        #expect(Factors.poseidonUra.calculationType == .CommonSe)
    }
    
    @Test("Factors: calculationType - CommonSe for trans-Neptunian objects")
    func testCalculationTypeCommonSeForTNOs() {
        #expect(Factors.eris.calculationType == .CommonSe)
        #expect(Factors.nessus.calculationType == .CommonSe)
        #expect(Factors.huya.calculationType == .CommonSe)
        #expect(Factors.varuna.calculationType == .CommonSe)
        #expect(Factors.ixion.calculationType == .CommonSe)
        #expect(Factors.quaoar.calculationType == .CommonSe)
        #expect(Factors.haumea.calculationType == .CommonSe)
        #expect(Factors.orcus.calculationType == .CommonSe)
        #expect(Factors.makemake.calculationType == .CommonSe)
        #expect(Factors.sedna.calculationType == .CommonSe)
        #expect(Factors.isis.calculationType == .CommonSe)
    }
    
    @Test("Factors: calculationType - CommonElements for RAM factors")
    func testCalculationTypeCommonElements() {
        #expect(Factors.persephoneRam.calculationType == .CommonElements)
        #expect(Factors.hermesRam.calculationType == .CommonElements)
        #expect(Factors.demeterRam.calculationType == .CommonElements)
    }
    
    @Test("Factors: calculationType - CommonFormulaLongitude for Carteret factors")
    func testCalculationTypeCommonFormulaLongitude() {
        #expect(Factors.persephoneCarteret.calculationType == .CommonFormulaLongitude)
        #expect(Factors.vulcanusCarteret.calculationType == .CommonFormulaLongitude)
    }
    
    @Test("Factors: calculationType - CommonFormulaFull for formula factors")
    func testCalculationTypeCommonFormulaFull() {
        #expect(Factors.priapus.calculationType == .CommonFormulaFull)
        #expect(Factors.priapusCorrected.calculationType == .CommonFormulaFull)
        #expect(Factors.dragon.calculationType == .CommonFormulaFull)
        #expect(Factors.beast.calculationType == .CommonFormulaFull)
        #expect(Factors.southNodeMean.calculationType == .CommonFormulaFull)
        #expect(Factors.southNodeTrue.calculationType == .CommonFormulaFull)
    }
    
    @Test("Factors: calculationType - Mundane for house system factors")
    func testCalculationTypeMundane() {
        #expect(Factors.mc.calculationType == .Mundane)
        #expect(Factors.ascendant.calculationType == .Mundane)
        #expect(Factors.eastPoint.calculationType == .Mundane)
        #expect(Factors.vertex.calculationType == .Mundane)
    }
    
    @Test("Factors: calculationType - ZodiacFixed for fixed zodiac points")
    func testCalculationTypeZodiacFixed() {
        #expect(Factors.zeroAries.calculationType == .ZodiacFixed)
    }
    
    @Test("Factors: calculationType - Lots for lot calculations")
    func testCalculationTypeLots() {
        #expect(Factors.fortunaSect.calculationType == .Lots)
        #expect(Factors.fortunaNoSect.calculationType == .Lots)
    }
    
    @Test("Factors: calculationType - Apsides for apside calculations")
    func testCalculationTypeApsides() {
        #expect(Factors.blackSun.calculationType == .Apsides)
        #expect(Factors.diamond.calculationType == .Apsides)
    }
    
    // MARK: - SE ID Tests
    
    @Test("Factors: seId - major planets")
    func testSeIdMajorPlanets() {
        #expect(Factors.sun.seId == 0)
        #expect(Factors.moon.seId == 1)
        #expect(Factors.mercury.seId == 2)
        #expect(Factors.venus.seId == 3)
        #expect(Factors.mars.seId == 4)
        #expect(Factors.jupiter.seId == 5)
        #expect(Factors.saturn.seId == 6)
        #expect(Factors.uranus.seId == 7)
        #expect(Factors.neptune.seId == 8)
        #expect(Factors.pluto.seId == 9)
    }
    
    @Test("Factors: seId - nodes and apogees")
    func testSeIdNodesAndApogees() {
        #expect(Factors.northNodeMean.seId == 10)
        #expect(Factors.northNodeTrue.seId == 11)
        #expect(Factors.apogeeMean.seId == 12)
        #expect(Factors.apogeeCorrected.seId == 13)
        #expect(Factors.earth.seId == 14)
        #expect(Factors.apogeeInterpolated.seId == 21)
        #expect(Factors.perigeeInterpolated.seId == 22)
    }
    
    @Test("Factors: seId - asteroids")
    func testSeIdAsteroids() {
        #expect(Factors.chiron.seId == 15)
        #expect(Factors.pholus.seId == 16)
        #expect(Factors.ceres.seId == 17)
        #expect(Factors.pallas.seId == 18)
        #expect(Factors.juno.seId == 19)
        #expect(Factors.vesta.seId == 20)
        #expect(Factors.hygieia.seId == 10010)
        #expect(Factors.astraea.seId == 10005)
    }
    
    @Test("Factors: seId - Uranian planets")
    func testSeIdUranian() {
        #expect(Factors.cupidoUra.seId == 40)
        #expect(Factors.hadesUra.seId == 41)
        #expect(Factors.zeusUra.seId == 42)
        #expect(Factors.kronosUra.seId == 43)
        #expect(Factors.apollonUra.seId == 44)
        #expect(Factors.admetosUra.seId == 45)
        #expect(Factors.vulcanusUra.seId == 46)
        #expect(Factors.poseidonUra.seId == 47)
        #expect(Factors.isis.seId == 48)
    }
    
    @Test("Factors: seId - trans-Neptunian objects")
    func testSeIdTNOs() {
        #expect(Factors.eris.seId == 1009001)
        #expect(Factors.nessus.seId == 17066)
        #expect(Factors.huya.seId == 48628)
        #expect(Factors.varuna.seId == 30000)
        #expect(Factors.ixion.seId == 38978)
        #expect(Factors.quaoar.seId == 60000)
        #expect(Factors.haumea.seId == 146108)
        #expect(Factors.orcus.seId == 100482)
        #expect(Factors.makemake.seId == 146472)
        #expect(Factors.sedna.seId == 100377)
    }
    
    @Test("Factors: seId - RAM factors")
    func testSeIdRAM() {
        #expect(Factors.persephoneRam.seId == 300)
        #expect(Factors.hermesRam.seId == 301)
        #expect(Factors.demeterRam.seId == 302)
    }
    
    @Test("Factors: seId - Carteret factors")
    func testSeIdCarteret() {
        #expect(Factors.persephoneCarteret.seId == 400)
        #expect(Factors.vulcanusCarteret.seId == 401)
    }
    
    @Test("Factors: seId - formula factors")
    func testSeIdFormula() {
        #expect(Factors.priapus.seId == 501)
        #expect(Factors.priapusCorrected.seId == 502)
        #expect(Factors.dragon.seId == 503)
        #expect(Factors.beast.seId == 504)
        #expect(Factors.southNodeMean.seId == 505)
        #expect(Factors.southNodeTrue.seId == 506)
    }
    
    @Test("Factors: seId - apsides")
    func testSeIdApsides() {
        #expect(Factors.blackSun.seId == 601)
        #expect(Factors.diamond.seId == 602)
    }
    
    @Test("Factors: seId - mundane points")
    func testSeIdMundane() {
        #expect(Factors.mc.seId == 700)
        #expect(Factors.ascendant.seId == 701)
        #expect(Factors.eastPoint.seId == 702)
        #expect(Factors.vertex.seId == 703)
    }
    
    @Test("Factors: seId - fixed points and lots")
    func testSeIdFixedAndLots() {
        #expect(Factors.zeroAries.seId == 800)
        #expect(Factors.fortunaSect.seId == 900)
        #expect(Factors.fortunaNoSect.seId == 901)
    }
    
    // MARK: - LocalizedName Tests
    
    @Test("Factors: localizedName - major planets")
    func testLocalizedNameMajorPlanets() {
        #expect(Factors.sun.localizedName == "enum.factor.sun")
        #expect(Factors.moon.localizedName == "enum.factor.moon")
        #expect(Factors.mercury.localizedName == "enum.factor.mercury")
        #expect(Factors.venus.localizedName == "enum.factor.venus")
        #expect(Factors.earth.localizedName == "enum.factor.earth")
        #expect(Factors.mars.localizedName == "enum.factor.mars")
        #expect(Factors.jupiter.localizedName == "enum.factor.jupiter")
        #expect(Factors.saturn.localizedName == "enum.factor.saturn")
        #expect(Factors.uranus.localizedName == "enum.factor.uranus")
        #expect(Factors.neptune.localizedName == "enum.factor.neptune")
        #expect(Factors.pluto.localizedName == "enum.factor.pluto")
    }
    
    @Test("Factors: localizedName - nodes")
    func testLocalizedNameNodes() {
        #expect(Factors.northNodeMean.localizedName == "enum.factor.northnode")
        #expect(Factors.northNodeTrue.localizedName == "enum.factor.truenode")
        #expect(Factors.southNodeMean.localizedName == "enum.factor.southnodemean")
        #expect(Factors.southNodeTrue.localizedName == "enum.factor.southnodetrue")
    }
    
    @Test("Factors: localizedName - asteroids")
    func testLocalizedNameAsteroids() {
        #expect(Factors.chiron.localizedName == "enum.factor.chiron")
        #expect(Factors.ceres.localizedName == "enum.factor.ceres")
        #expect(Factors.pallas.localizedName == "enum.factor.pallas")
        #expect(Factors.juno.localizedName == "enum.factor.juno")
        #expect(Factors.vesta.localizedName == "enum.factor.vesta")
    }
    
    @Test("Factors: localizedName - mundane points")
    func testLocalizedNameMundane() {
        #expect(Factors.ascendant.localizedName == "enum.factor.ascendant")
        #expect(Factors.mc.localizedName == "enum.factor.mc")
        #expect(Factors.eastPoint.localizedName == "enum.factor.eastpoint")
        #expect(Factors.vertex.localizedName == "enum.factor.vertex")
    }
    
    @Test("Factors: localizedName - lots")
    func testLocalizedNameLots() {
        #expect(Factors.fortunaSect.localizedName == "enum.factor.fortunasect")
        #expect(Factors.fortunaNoSect.localizedName == "enum.factor.fortunanosect")
    }
    
    @Test("Factors: localizedName - all factors have localization keys")
    func testLocalizedNameAllFactors() {
        for factor in Factors.allCases {
            let name = factor.localizedName
            #expect(!name.isEmpty)
            #expect(name.hasPrefix("enum.factor."))
        }
    }
    
    // MARK: - FromIndex Tests
    
    @Test("Factors: fromIndex - valid indices")
    func testFromIndexValid() {
        let allCases = Array(Factors.allCases)
        for (index, expectedFactor) in allCases.enumerated() {
            let factor = Factors.fromIndex(index)
            #expect(factor == expectedFactor)
        }
    }
    
    @Test("Factors: fromIndex - first index")
    func testFromIndexFirst() {
        let factor = Factors.fromIndex(0)
        #expect(factor == Factors.allCases.first)
    }
    
    @Test("Factors: fromIndex - last index")
    func testFromIndexLast() {
        let lastIndex = Factors.allCases.count - 1
        let factor = Factors.fromIndex(lastIndex)
        #expect(factor == Factors.allCases.last)
    }
    
    @Test("Factors: fromIndex - negative index")
    func testFromIndexNegative() {
        let factor = Factors.fromIndex(-1)
        #expect(factor == nil)
    }
    
    @Test("Factors: fromIndex - index too large")
    func testFromIndexTooLarge() {
        let tooLargeIndex = Factors.allCases.count
        let factor = Factors.fromIndex(tooLargeIndex)
        #expect(factor == nil)
    }
    
    @Test("Factors: fromIndex - index at boundary")
    func testFromIndexBoundary() {
        let boundaryIndex = Factors.allCases.count
        let factor = Factors.fromIndex(boundaryIndex)
        #expect(factor == nil)
        
        let validBoundaryIndex = Factors.allCases.count - 1
        let validFactor = Factors.fromIndex(validBoundaryIndex)
        #expect(validFactor != nil)
    }
    
    // MARK: - Raw Value Tests
    
    @Test("Factors: raw values are unique")
    func testRawValuesUnique() {
        var rawValues: Set<Int> = []
        for factor in Factors.allCases {
            let rawValue = factor.rawValue
            #expect(!rawValues.contains(rawValue), "Duplicate raw value \(rawValue) found")
            rawValues.insert(rawValue)
        }
    }
    
    @Test("Factors: raw values match expected values")
    func testRawValuesMatchExpected() {
        #expect(Factors.sun.rawValue == 0)
        #expect(Factors.moon.rawValue == 1)
        #expect(Factors.mercury.rawValue == 2)
        #expect(Factors.venus.rawValue == 3)
        #expect(Factors.earth.rawValue == 4)
        #expect(Factors.mars.rawValue == 5)
        #expect(Factors.jupiter.rawValue == 6)
        #expect(Factors.saturn.rawValue == 7)
        #expect(Factors.uranus.rawValue == 8)
        #expect(Factors.neptune.rawValue == 9)
        #expect(Factors.pluto.rawValue == 10)
        #expect(Factors.ascendant.rawValue == 1001)
        #expect(Factors.mc.rawValue == 1002)
        #expect(Factors.zeroAries.rawValue == 3001)
        #expect(Factors.fortunaSect.rawValue == 4001)
    }
    
    // MARK: - Comprehensive Tests
    
    @Test("Factors: all factors have valid calculation type")
    func testAllFactorsHaveValidCalculationType() {
        for factor in Factors.allCases {
            let calculationType = factor.calculationType
            // Verify that calculation type is not Unknown (which indicates unhandled case)
            #expect(calculationType != .Unknown, "Factor \(factor) has Unknown calculation type")
        }
    }
    
    @Test("Factors: all factors have SE ID")
    func testAllFactorsHaveSeId() {
        for factor in Factors.allCases {
            let seId = factor.seId
            // SE ID can be 0 for some factors, but should be defined
            #expect(seId >= 0)
        }
    }
    
    @Test("Factors: CommonSe factors have valid SE IDs")
    func testCommonSeFactorsHaveValidSeIds() {
        let commonSeFactors: [Factors] = [
            .sun, .moon, .mercury, .venus, .earth, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto,
            .northNodeMean, .northNodeTrue, .apogeeMean, .apogeeCorrected, .chiron, .pholus,
            .ceres, .pallas, .juno, .vesta, .apogeeInterpolated, .perigeeInterpolated,
            .cupidoUra, .hadesUra, .zeusUra, .kronosUra, .apollonUra, .admetosUra,
            .vulcanusUra, .poseidonUra, .isis, .eris, .nessus, .huya, .varuna, .ixion,
            .quaoar, .haumea, .orcus, .makemake, .sedna, .hygieia, .astraea
        ]
        
        for factor in commonSeFactors {
            #expect(factor.calculationType == .CommonSe)
            #expect(factor.seId > -1)  // -1 is used for obliquity
        }
    }
    
    @Test("Factors: consistency between calculation type and SE ID")
    func testCalculationTypeAndSeIdConsistency() {
        // Factors with CommonSe should generally have non-zero SE IDs
        // (except for edge cases that might use default)
        let commonSeFactors = Factors.allCases.filter { $0.calculationType == .CommonSe }
        
        for factor in commonSeFactors {
            // Most CommonSe factors should have meaningful SE IDs
            // Some might have 0 as default, but major ones should not
            if factor == .sun || factor == .moon || factor == .mercury || factor == .venus ||
               factor == .mars || factor == .jupiter || factor == .saturn ||
               factor == .uranus || factor == .neptune || factor == .pluto {
                #expect(factor.seId >= 0 && factor.seId <= 9)
            }
        }
    }
    
    @Test("Factors: enum is CaseIterable")
    func testCaseIterable() {
        let allCases = Factors.allCases
        #expect(allCases.count > 0)
        
        // Verify we can iterate
        var count = 0
        for _ in allCases {
            count += 1
        }
        #expect(count == allCases.count)
    }
    
    @Test("Factors: enum is Int-backed")
    func testIntBacked() {
        // Test that we can create from raw value
        if let sun = Factors(rawValue: 0) {
            #expect(sun == .sun)
        } else {
            Issue.record("Failed to create Factors from rawValue 0")
        }
        
        if let moon = Factors(rawValue: 1) {
            #expect(moon == .moon)
        } else {
            Issue.record("Failed to create Factors from rawValue 1")
        }
    }
}

