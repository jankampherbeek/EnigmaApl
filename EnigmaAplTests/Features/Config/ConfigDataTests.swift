//
//  ConfigDataTests.swift
//  EnigmaAplTests
//
//  Created on 01/01/2026.
//

import Testing
@testable import EnigmaApl

struct ConfigDataTests {
    
    // MARK: - Initialization Tests
    
    @Test("ConfigData: initialization with all parameters")
    func testConfigDataInitialization() {
        let houseSystem = HouseSystems.placidus
        let ayanamsha = Ayanamshas.tropical
        let observerPosition = ObserverPositions.geoCentric
        let projectionType = ProjectionTypes.twoDimensional
        let blackMoonCorrectionType = BlackMoonCorrectionTypes.duval
        let lunarNodeType = LunarNodeTypes.meanNode
        let lotsType = LotsTypes.sect
        
        let configData = ConfigData(
            houseSystem: houseSystem,
            ayanamsha: ayanamsha,
            observerPosition: observerPosition,
            projectionType: projectionType,
            blackMoonCorrectionType: blackMoonCorrectionType,
            lunarNodeType: lunarNodeType,
            lotsType: lotsType
        )
        
        #expect(configData.houseSystem == houseSystem)
        #expect(configData.ayanamsha == ayanamsha)
        #expect(configData.observerPosition == observerPosition)
        #expect(configData.projectionType == projectionType)
        #expect(configData.blackMoonCorrectionType == blackMoonCorrectionType)
        #expect(configData.lunarNodeType == lunarNodeType)
        #expect(configData.lotsType == lotsType)
    }
    
    @Test("ConfigData: initialization with default values")
    func testConfigDataWithDefaultValues() {
        let configData = ConfigData(
            houseSystem: .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        #expect(configData.houseSystem == .noHouses)
        #expect(configData.ayanamsha == .tropical)
        #expect(configData.observerPosition == .geoCentric)
        #expect(configData.projectionType == .twoDimensional)
        #expect(configData.blackMoonCorrectionType == .duval)
        #expect(configData.lunarNodeType == .meanNode)
        #expect(configData.lotsType == .sect)
    }
    
    // MARK: - Property Access Tests
    
    @Test("ConfigData: property access for houseSystem")
    func testHouseSystemProperty() {
        let configData = ConfigData(
            houseSystem: .regiomontanus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        #expect(configData.houseSystem == .regiomontanus)
        #expect(configData.houseSystem.rawValue == 4)
    }
    
    @Test("ConfigData: property access for ayanamsha")
    func testAyanamshaProperty() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .lahiri,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        #expect(configData.ayanamsha == .lahiri)
        #expect(configData.ayanamsha.rawValue == 2)
    }
    
    @Test("ConfigData: property access for observerPosition")
    func testObserverPositionProperty() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        #expect(configData.observerPosition == .topoCentric)
        #expect(configData.observerPosition.rawValue == 1)
    }
    
    @Test("ConfigData: property access for projectionType")
    func testProjectionTypeProperty() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .obliqueLongitude,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        #expect(configData.projectionType == .obliqueLongitude)
        #expect(configData.projectionType.rawValue == 1)
    }
    
    @Test("ConfigData: property access for blackMoonCorrectionType")
    func testBlackMoonCorrectionTypeProperty() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .swisseph,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        #expect(configData.blackMoonCorrectionType == .swisseph)
        #expect(configData.blackMoonCorrectionType.rawValue == 1)
    }
    
    @Test("ConfigData: property access for lunarNodeType")
    func testLunarNodeTypeProperty() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .trueNode,
            lotsType: .sect
        )
        
        #expect(configData.lunarNodeType == .trueNode)
        #expect(configData.lunarNodeType.rawValue == 1)
    }
    
    @Test("ConfigData: property access for lotsType")
    func testLotsTypeProperty() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .noSect
        )
        
        #expect(configData.lotsType == .noSect)
        #expect(configData.lotsType.rawValue == 1)
    }
    
    // MARK: - All Enum Cases Tests
    
    @Test("ConfigData: all house systems can be used")
    func testAllHouseSystems() {
        for houseSystem in HouseSystems.allCases {
            let configData = ConfigData(
                houseSystem: houseSystem,
                ayanamsha: .tropical,
                observerPosition: .geoCentric,
                projectionType: .twoDimensional,
                blackMoonCorrectionType: .duval,
                lunarNodeType: .meanNode,
                lotsType: .sect
            )
            
            #expect(configData.houseSystem == houseSystem)
        }
    }
    
    @Test("ConfigData: all ayanamshas can be used")
    func testAllAyanamshas() {
        for ayanamsha in Ayanamshas.allCases {
            let configData = ConfigData(
                houseSystem: .placidus,
                ayanamsha: ayanamsha,
                observerPosition: .geoCentric,
                projectionType: .twoDimensional,
                blackMoonCorrectionType: .duval,
                lunarNodeType: .meanNode,
                lotsType: .sect
            )
            
            #expect(configData.ayanamsha == ayanamsha)
        }
    }
    
    @Test("ConfigData: all observer positions can be used")
    func testAllObserverPositions() {
        for observerPosition in ObserverPositions.allCases {
            let configData = ConfigData(
                houseSystem: .placidus,
                ayanamsha: .tropical,
                observerPosition: observerPosition,
                projectionType: .twoDimensional,
                blackMoonCorrectionType: .duval,
                lunarNodeType: .meanNode,
                lotsType: .sect
            )
            
            #expect(configData.observerPosition == observerPosition)
        }
    }
    
    @Test("ConfigData: all projection types can be used")
    func testAllProjectionTypes() {
        for projectionType in ProjectionTypes.allCases {
            let configData = ConfigData(
                houseSystem: .placidus,
                ayanamsha: .tropical,
                observerPosition: .geoCentric,
                projectionType: projectionType,
                blackMoonCorrectionType: .duval,
                lunarNodeType: .meanNode,
                lotsType: .sect
            )
            
            #expect(configData.projectionType == projectionType)
        }
    }
    
    @Test("ConfigData: all black moon correction types can be used")
    func testAllBlackMoonCorrectionTypes() {
        for blackMoonCorrectionType in BlackMoonCorrectionTypes.allCases {
            let configData = ConfigData(
                houseSystem: .placidus,
                ayanamsha: .tropical,
                observerPosition: .geoCentric,
                projectionType: .twoDimensional,
                blackMoonCorrectionType: blackMoonCorrectionType,
                lunarNodeType: .meanNode,
                lotsType: .sect
            )
            
            #expect(configData.blackMoonCorrectionType == blackMoonCorrectionType)
        }
    }
    
    @Test("ConfigData: all lunar node types can be used")
    func testAllLunarNodeTypes() {
        for lunarNodeType in LunarNodeTypes.allCases {
            let configData = ConfigData(
                houseSystem: .placidus,
                ayanamsha: .tropical,
                observerPosition: .geoCentric,
                projectionType: .twoDimensional,
                blackMoonCorrectionType: .duval,
                lunarNodeType: lunarNodeType,
                lotsType: .sect
            )
            
            #expect(configData.lunarNodeType == lunarNodeType)
        }
    }
    
    @Test("ConfigData: all lots types can be used")
    func testAllLotsTypes() {
        for lotsType in LotsTypes.allCases {
            let configData = ConfigData(
                houseSystem: .placidus,
                ayanamsha: .tropical,
                observerPosition: .geoCentric,
                projectionType: .twoDimensional,
                blackMoonCorrectionType: .duval,
                lunarNodeType: .meanNode,
                lotsType: lotsType
            )
            
            #expect(configData.lotsType == lotsType)
        }
    }
    
    // MARK: - Combination Tests
    
    @Test("ConfigData: different combinations of enum values")
    func testDifferentCombinations() {
        // Test combination 1: Placidus, Tropical, Geocentric, TwoDimensional, Duval, MeanNode, Sect
        let config1 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        #expect(config1.houseSystem == .placidus)
        #expect(config1.ayanamsha == .tropical)
        #expect(config1.observerPosition == .geoCentric)
        #expect(config1.projectionType == .twoDimensional)
        #expect(config1.blackMoonCorrectionType == .duval)
        #expect(config1.lunarNodeType == .meanNode)
        #expect(config1.lotsType == .sect)
        
        // Test combination 2: Regiomontanus, Lahiri, Topocentric, ObliqueLongitude, SwissEph, TrueNode, NoSect
        let config2 = ConfigData(
            houseSystem: .regiomontanus,
            ayanamsha: .lahiri,
            observerPosition: .topoCentric,
            projectionType: .obliqueLongitude,
            blackMoonCorrectionType: .swisseph,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        #expect(config2.houseSystem == .regiomontanus)
        #expect(config2.ayanamsha == .lahiri)
        #expect(config2.observerPosition == .topoCentric)
        #expect(config2.projectionType == .obliqueLongitude)
        #expect(config2.blackMoonCorrectionType == .swisseph)
        #expect(config2.lunarNodeType == .trueNode)
        #expect(config2.lotsType == .noSect)
        
        // Test combination 3: Koch, Fagan, Heliocentric, TwoDimensional, Interpolated, MeanNode, Sect
        let config3 = ConfigData(
            houseSystem: .koch,
            ayanamsha: .fagan,
            observerPosition: .helioCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .interpolated,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        #expect(config3.houseSystem == .koch)
        #expect(config3.ayanamsha == .fagan)
        #expect(config3.observerPosition == .helioCentric)
        #expect(config3.projectionType == .twoDimensional)
        #expect(config3.blackMoonCorrectionType == .interpolated)
        #expect(config3.lunarNodeType == .meanNode)
        #expect(config3.lotsType == .sect)
        
        // Test combination 4: Whole Sign, Krishnamurti, Geocentric, ObliqueLongitude, Duval, TrueNode, NoSect
        let config4 = ConfigData(
            houseSystem: .wholeSign,
            ayanamsha: .krishnamurti,
            observerPosition: .geoCentric,
            projectionType: .obliqueLongitude,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        #expect(config4.houseSystem == .wholeSign)
        #expect(config4.ayanamsha == .krishnamurti)
        #expect(config4.observerPosition == .geoCentric)
        #expect(config4.projectionType == .obliqueLongitude)
        #expect(config4.blackMoonCorrectionType == .duval)
        #expect(config4.lunarNodeType == .trueNode)
        #expect(config4.lotsType == .noSect)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("ConfigData: first enum values")
    func testFirstEnumValues() {
        let configData = ConfigData(
            houseSystem: .noHouses,  // First house system
            ayanamsha: .tropical,   // First ayanamsha
            observerPosition: .geoCentric,  // First observer position
            projectionType: .twoDimensional,  // First projection type
            blackMoonCorrectionType: .duval,  // First black moon correction type
            lunarNodeType: .meanNode,  // First lunar node type
            lotsType: .sect  // First lots type
        )
        
        #expect(configData.houseSystem.rawValue == 0)
        #expect(configData.ayanamsha.rawValue == 0)
        #expect(configData.observerPosition.rawValue == 0)
        #expect(configData.projectionType.rawValue == 0)
        #expect(configData.blackMoonCorrectionType.rawValue == 0)
        #expect(configData.lunarNodeType.rawValue == 0)
        #expect(configData.lotsType.rawValue == 0)
    }
    
    @Test("ConfigData: last enum values")
    func testLastEnumValues() {
        let lastHouseSystem = HouseSystems.allCases.last!
        let lastAyanamsha = Ayanamshas.allCases.last!
        let lastObserverPosition = ObserverPositions.allCases.last!
        let lastProjectionType = ProjectionTypes.allCases.last!
        let lastBlackMoonCorrectionType = BlackMoonCorrectionTypes.allCases.last!
        let lastLunarNodeType = LunarNodeTypes.allCases.last!
        let lastLotsType = LotsTypes.allCases.last!
        
        let configData = ConfigData(
            houseSystem: lastHouseSystem,
            ayanamsha: lastAyanamsha,
            observerPosition: lastObserverPosition,
            projectionType: lastProjectionType,
            blackMoonCorrectionType: lastBlackMoonCorrectionType,
            lunarNodeType: lastLunarNodeType,
            lotsType: lastLotsType
        )
        
        #expect(configData.houseSystem == lastHouseSystem)
        #expect(configData.ayanamsha == lastAyanamsha)
        #expect(configData.observerPosition == lastObserverPosition)
        #expect(configData.projectionType == lastProjectionType)
        #expect(configData.blackMoonCorrectionType == lastBlackMoonCorrectionType)
        #expect(configData.lunarNodeType == lastLunarNodeType)
        #expect(configData.lotsType == lastLotsType)
    }
    
    // MARK: - Immutability Tests
    
    @Test("ConfigData: properties are immutable after initialization")
    func testImmutability() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        // Properties are let, so they cannot be changed
        // This test verifies that the values remain constant
        let initialHouseSystem = configData.houseSystem
        let initialAyanamsha = configData.ayanamsha
        let initialObserverPosition = configData.observerPosition
        let initialProjectionType = configData.projectionType
        let initialBlackMoonCorrectionType = configData.blackMoonCorrectionType
        let initialLunarNodeType = configData.lunarNodeType
        let initialLotsType = configData.lotsType
        
        // Create a new instance to verify immutability
        let newConfigData = ConfigData(
            houseSystem: .koch,
            ayanamsha: .lahiri,
            observerPosition: .topoCentric,
            projectionType: .obliqueLongitude,
            blackMoonCorrectionType: .swisseph,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        
        // Original instance should remain unchanged
        #expect(configData.houseSystem == initialHouseSystem)
        #expect(configData.ayanamsha == initialAyanamsha)
        #expect(configData.observerPosition == initialObserverPosition)
        #expect(configData.projectionType == initialProjectionType)
        #expect(configData.blackMoonCorrectionType == initialBlackMoonCorrectionType)
        #expect(configData.lunarNodeType == initialLunarNodeType)
        #expect(configData.lotsType == initialLotsType)
        
        // New instance should have different values
        #expect(newConfigData.houseSystem != configData.houseSystem)
        #expect(newConfigData.ayanamsha != configData.ayanamsha)
        #expect(newConfigData.observerPosition != configData.observerPosition)
        #expect(newConfigData.projectionType != configData.projectionType)
        #expect(newConfigData.blackMoonCorrectionType != configData.blackMoonCorrectionType)
        #expect(newConfigData.lunarNodeType != configData.lunarNodeType)
        #expect(newConfigData.lotsType != configData.lotsType)
    }
    
    // MARK: - Equality Tests
    
    @Test("ConfigData: two instances with same values")
    func testEquality() {
        let config1 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        let config2 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        // Structs with same values should have same property values
        #expect(config1.houseSystem == config2.houseSystem)
        #expect(config1.ayanamsha == config2.ayanamsha)
        #expect(config1.observerPosition == config2.observerPosition)
        #expect(config1.projectionType == config2.projectionType)
        #expect(config1.blackMoonCorrectionType == config2.blackMoonCorrectionType)
        #expect(config1.lunarNodeType == config2.lunarNodeType)
        #expect(config1.lotsType == config2.lotsType)
    }
    
    @Test("ConfigData: two instances with different values")
    func testInequality() {
        let config1 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        let config2 = ConfigData(
            houseSystem: .koch,
            ayanamsha: .lahiri,
            observerPosition: .topoCentric,
            projectionType: .obliqueLongitude,
            blackMoonCorrectionType: .swisseph,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        
        // Structs with different values should have different property values
        #expect(config1.houseSystem != config2.houseSystem)
        #expect(config1.ayanamsha != config2.ayanamsha)
        #expect(config1.observerPosition != config2.observerPosition)
        #expect(config1.projectionType != config2.projectionType)
        #expect(config1.blackMoonCorrectionType != config2.blackMoonCorrectionType)
        #expect(config1.lunarNodeType != config2.lunarNodeType)
        #expect(config1.lotsType != config2.lotsType)
    }
    
    // MARK: - Specific Use Case Tests
    
    @Test("ConfigData: common astrological configurations")
    func testCommonConfigurations() {
        // Western/Tropical configuration
        let westernConfig = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        #expect(westernConfig.houseSystem == .placidus)
        #expect(westernConfig.ayanamsha == .tropical)
        #expect(westernConfig.observerPosition == .geoCentric)
        #expect(westernConfig.projectionType == .twoDimensional)
        #expect(westernConfig.blackMoonCorrectionType == .duval)
        #expect(westernConfig.lunarNodeType == .meanNode)
        #expect(westernConfig.lotsType == .sect)
        
        // Vedic/Sidereal configuration
        let vedicConfig = ConfigData(
            houseSystem: .wholeSign,
            ayanamsha: .lahiri,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .swisseph,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        #expect(vedicConfig.houseSystem == .wholeSign)
        #expect(vedicConfig.ayanamsha == .lahiri)
        #expect(vedicConfig.observerPosition == .geoCentric)
        #expect(vedicConfig.projectionType == .twoDimensional)
        #expect(vedicConfig.blackMoonCorrectionType == .swisseph)
        #expect(vedicConfig.lunarNodeType == .trueNode)
        #expect(vedicConfig.lotsType == .noSect)
        
        // Topocentric configuration
        let topocentricConfig = ConfigData(
            houseSystem: .topoCentric,
            ayanamsha: .tropical,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .interpolated,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        #expect(topocentricConfig.houseSystem == .topoCentric)
        #expect(topocentricConfig.ayanamsha == .tropical)
        #expect(topocentricConfig.observerPosition == .topoCentric)
        #expect(topocentricConfig.projectionType == .twoDimensional)
        #expect(topocentricConfig.blackMoonCorrectionType == .interpolated)
        #expect(topocentricConfig.lunarNodeType == .meanNode)
        #expect(topocentricConfig.lotsType == .sect)
        
        // Oblique Longitude configuration (School of Ram)
        let obliqueConfig = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .obliqueLongitude,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        #expect(obliqueConfig.houseSystem == .placidus)
        #expect(obliqueConfig.ayanamsha == .tropical)
        #expect(obliqueConfig.observerPosition == .geoCentric)
        #expect(obliqueConfig.projectionType == .obliqueLongitude)
        #expect(obliqueConfig.blackMoonCorrectionType == .duval)
        #expect(obliqueConfig.lunarNodeType == .trueNode)
        #expect(obliqueConfig.lotsType == .noSect)
    }
    
    // MARK: - Raw Value Tests
    
    @Test("ConfigData: raw values are preserved")
    func testRawValuesPreserved() {
        let configData = ConfigData(
            houseSystem: .regiomontanus,
            ayanamsha: .krishnamurti,
            observerPosition: .helioCentric,
            projectionType: .obliqueLongitude,
            blackMoonCorrectionType: .interpolated,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        
        #expect(configData.houseSystem.rawValue == 4)
        #expect(configData.ayanamsha.rawValue == 6)
        #expect(configData.observerPosition.rawValue == 2)
        #expect(configData.projectionType.rawValue == 1)
        #expect(configData.blackMoonCorrectionType.rawValue == 2)
        #expect(configData.lunarNodeType.rawValue == 1)
        #expect(configData.lotsType.rawValue == 1)
    }
}

