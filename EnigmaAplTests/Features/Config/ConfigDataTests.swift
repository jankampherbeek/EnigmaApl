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
        
        let configData = ConfigData(
            houseSystem: houseSystem,
            ayanamsha: ayanamsha,
            observerPosition: observerPosition,
            projectionType: projectionType
        )
        
        #expect(configData.houseSystem == houseSystem)
        #expect(configData.ayanamsha == ayanamsha)
        #expect(configData.observerPosition == observerPosition)
        #expect(configData.projectionType == projectionType)
    }
    
    @Test("ConfigData: initialization with default values")
    func testConfigDataWithDefaultValues() {
        let configData = ConfigData(
            houseSystem: .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        
        #expect(configData.houseSystem == .noHouses)
        #expect(configData.ayanamsha == .tropical)
        #expect(configData.observerPosition == .geoCentric)
        #expect(configData.projectionType == .twoDimensional)
    }
    
    // MARK: - Property Access Tests
    
    @Test("ConfigData: property access for houseSystem")
    func testHouseSystemProperty() {
        let configData = ConfigData(
            houseSystem: .regiomontanus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
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
            projectionType: .twoDimensional
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
            projectionType: .twoDimensional
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
            projectionType: .obliqueLongitude
        )
        
        #expect(configData.projectionType == .obliqueLongitude)
        #expect(configData.projectionType.rawValue == 1)
    }
    
    // MARK: - All Enum Cases Tests
    
    @Test("ConfigData: all house systems can be used")
    func testAllHouseSystems() {
        for houseSystem in HouseSystems.allCases {
            let configData = ConfigData(
                houseSystem: houseSystem,
                ayanamsha: .tropical,
                observerPosition: .geoCentric,
                projectionType: .twoDimensional
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
                projectionType: .twoDimensional
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
                projectionType: .twoDimensional
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
                projectionType: projectionType
            )
            
            #expect(configData.projectionType == projectionType)
        }
    }
    
    // MARK: - Combination Tests
    
    @Test("ConfigData: different combinations of enum values")
    func testDifferentCombinations() {
        // Test combination 1: Placidus, Tropical, Geocentric, TwoDimensional
        let config1 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        #expect(config1.houseSystem == .placidus)
        #expect(config1.ayanamsha == .tropical)
        #expect(config1.observerPosition == .geoCentric)
        #expect(config1.projectionType == .twoDimensional)
        
        // Test combination 2: Regiomontanus, Lahiri, Topocentric, ObliqueLongitude
        let config2 = ConfigData(
            houseSystem: .regiomontanus,
            ayanamsha: .lahiri,
            observerPosition: .topoCentric,
            projectionType: .obliqueLongitude
        )
        #expect(config2.houseSystem == .regiomontanus)
        #expect(config2.ayanamsha == .lahiri)
        #expect(config2.observerPosition == .topoCentric)
        #expect(config2.projectionType == .obliqueLongitude)
        
        // Test combination 3: Koch, Fagan, Heliocentric, TwoDimensional
        let config3 = ConfigData(
            houseSystem: .koch,
            ayanamsha: .fagan,
            observerPosition: .helioCentric,
            projectionType: .twoDimensional
        )
        #expect(config3.houseSystem == .koch)
        #expect(config3.ayanamsha == .fagan)
        #expect(config3.observerPosition == .helioCentric)
        #expect(config3.projectionType == .twoDimensional)
        
        // Test combination 4: Whole Sign, Krishnamurti, Geocentric, ObliqueLongitude
        let config4 = ConfigData(
            houseSystem: .wholeSign,
            ayanamsha: .krishnamurti,
            observerPosition: .geoCentric,
            projectionType: .obliqueLongitude
        )
        #expect(config4.houseSystem == .wholeSign)
        #expect(config4.ayanamsha == .krishnamurti)
        #expect(config4.observerPosition == .geoCentric)
        #expect(config4.projectionType == .obliqueLongitude)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("ConfigData: first enum values")
    func testFirstEnumValues() {
        let configData = ConfigData(
            houseSystem: .noHouses,  // First house system
            ayanamsha: .tropical,   // First ayanamsha
            observerPosition: .geoCentric,  // First observer position
            projectionType: .twoDimensional  // First projection type
        )
        
        #expect(configData.houseSystem.rawValue == 0)
        #expect(configData.ayanamsha.rawValue == 0)
        #expect(configData.observerPosition.rawValue == 0)
        #expect(configData.projectionType.rawValue == 0)
    }
    
    @Test("ConfigData: last enum values")
    func testLastEnumValues() {
        let lastHouseSystem = HouseSystems.allCases.last!
        let lastAyanamsha = Ayanamshas.allCases.last!
        let lastObserverPosition = ObserverPositions.allCases.last!
        let lastProjectionType = ProjectionTypes.allCases.last!
        
        let configData = ConfigData(
            houseSystem: lastHouseSystem,
            ayanamsha: lastAyanamsha,
            observerPosition: lastObserverPosition,
            projectionType: lastProjectionType
        )
        
        #expect(configData.houseSystem == lastHouseSystem)
        #expect(configData.ayanamsha == lastAyanamsha)
        #expect(configData.observerPosition == lastObserverPosition)
        #expect(configData.projectionType == lastProjectionType)
    }
    
    // MARK: - Immutability Tests
    
    @Test("ConfigData: properties are immutable after initialization")
    func testImmutability() {
        let configData = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        
        // Properties are let, so they cannot be changed
        // This test verifies that the values remain constant
        let initialHouseSystem = configData.houseSystem
        let initialAyanamsha = configData.ayanamsha
        let initialObserverPosition = configData.observerPosition
        let initialProjectionType = configData.projectionType
        
        // Create a new instance to verify immutability
        let newConfigData = ConfigData(
            houseSystem: .koch,
            ayanamsha: .lahiri,
            observerPosition: .topoCentric,
            projectionType: .obliqueLongitude
        )
        
        // Original instance should remain unchanged
        #expect(configData.houseSystem == initialHouseSystem)
        #expect(configData.ayanamsha == initialAyanamsha)
        #expect(configData.observerPosition == initialObserverPosition)
        #expect(configData.projectionType == initialProjectionType)
        
        // New instance should have different values
        #expect(newConfigData.houseSystem != configData.houseSystem)
        #expect(newConfigData.ayanamsha != configData.ayanamsha)
        #expect(newConfigData.observerPosition != configData.observerPosition)
        #expect(newConfigData.projectionType != configData.projectionType)
    }
    
    // MARK: - Equality Tests
    
    @Test("ConfigData: two instances with same values")
    func testEquality() {
        let config1 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        
        let config2 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        
        // Structs with same values should have same property values
        #expect(config1.houseSystem == config2.houseSystem)
        #expect(config1.ayanamsha == config2.ayanamsha)
        #expect(config1.observerPosition == config2.observerPosition)
        #expect(config1.projectionType == config2.projectionType)
    }
    
    @Test("ConfigData: two instances with different values")
    func testInequality() {
        let config1 = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        
        let config2 = ConfigData(
            houseSystem: .koch,
            ayanamsha: .lahiri,
            observerPosition: .topoCentric,
            projectionType: .obliqueLongitude
        )
        
        // Structs with different values should have different property values
        #expect(config1.houseSystem != config2.houseSystem)
        #expect(config1.ayanamsha != config2.ayanamsha)
        #expect(config1.observerPosition != config2.observerPosition)
        #expect(config1.projectionType != config2.projectionType)
    }
    
    // MARK: - Specific Use Case Tests
    
    @Test("ConfigData: common astrological configurations")
    func testCommonConfigurations() {
        // Western/Tropical configuration
        let westernConfig = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        #expect(westernConfig.houseSystem == .placidus)
        #expect(westernConfig.ayanamsha == .tropical)
        #expect(westernConfig.observerPosition == .geoCentric)
        #expect(westernConfig.projectionType == .twoDimensional)
        
        // Vedic/Sidereal configuration
        let vedicConfig = ConfigData(
            houseSystem: .wholeSign,
            ayanamsha: .lahiri,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional
        )
        #expect(vedicConfig.houseSystem == .wholeSign)
        #expect(vedicConfig.ayanamsha == .lahiri)
        #expect(vedicConfig.observerPosition == .geoCentric)
        #expect(vedicConfig.projectionType == .twoDimensional)
        
        // Topocentric configuration
        let topocentricConfig = ConfigData(
            houseSystem: .topoCentric,
            ayanamsha: .tropical,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional
        )
        #expect(topocentricConfig.houseSystem == .topoCentric)
        #expect(topocentricConfig.ayanamsha == .tropical)
        #expect(topocentricConfig.observerPosition == .topoCentric)
        #expect(topocentricConfig.projectionType == .twoDimensional)
        
        // Oblique Longitude configuration (School of Ram)
        let obliqueConfig = ConfigData(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .obliqueLongitude
        )
        #expect(obliqueConfig.houseSystem == .placidus)
        #expect(obliqueConfig.ayanamsha == .tropical)
        #expect(obliqueConfig.observerPosition == .geoCentric)
        #expect(obliqueConfig.projectionType == .obliqueLongitude)
    }
    
    // MARK: - Raw Value Tests
    
    @Test("ConfigData: raw values are preserved")
    func testRawValuesPreserved() {
        let configData = ConfigData(
            houseSystem: .regiomontanus,
            ayanamsha: .krishnamurti,
            observerPosition: .helioCentric,
            projectionType: .obliqueLongitude
        )
        
        #expect(configData.houseSystem.rawValue == 4)
        #expect(configData.ayanamsha.rawValue == 6)
        #expect(configData.observerPosition.rawValue == 2)
        #expect(configData.projectionType.rawValue == 1)
    }
}

