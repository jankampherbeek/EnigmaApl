//
//  AstronCalcTestCoordinator.swift
//  EnigmaAplTests
//
//  Created on 10/01/2026.
//
//  Coordinates all AstronCalc tests to run sequentially with a single SEWrapper instance.
//  This ensures thread-safety since Swiss Ephemeris is not thread-safe.
//  
//  To enable/disable specific tests, simply comment/uncomment the corresponding lines.
//  Other tests (non-AstronCalc) can still run in parallel.
//

import Testing
import Foundation
@testable import EnigmaApl

struct AstronCalcTestCoordinator {
    
    @Test("AstronCalc: Run all AstronCalc tests sequentially")
    @MainActor
    func runAllAstronCalcTests() async throws {
        // Create a single SEWrapper instance for all tests
        // This ensures thread-safety since Swiss Ephemeris is not thread-safe
        let seWrapper = SEWrapper()
        
        // Run tests sequentially - comment/uncomment tests as needed
        // Each test receives the same SEWrapper instance to prevent conflicts
        
        // LotsCalc Tests
        LotsCalcTests.testCalculateLotsFactorsNoSect(seWrapper: seWrapper)  // test failed
        // LotsCalcTests.testCalculateLotsFactorsSect(seWrapper: seWrapper)    // test succeeded
        
        // CommonElementsCalc Tests
        // CommonElementsCalcTests.testCalculateCommonElementsFactors(seWrapper: seWrapper)  // Test succeeded
        
        // SECalculation Tests
        // SECalculationTests.testCalculateFactors(seWrapper: seWrapper)       // Test succeeded
        
        // FormulaCalc Tests
        // FormulaCalcTests.testCalculateFormulaFactors(seWrapper: seWrapper)  // Test succeeded
        
        // ApsidesCalc Tests
        // ApsidesCalcTests.testCalculateApsidesFactors(seWrapper: seWrapper)  // Test succeede
        
        // AstronCalcOrchestrator Tests
        // AstronCalcOrchestratorTests.testPerformCalculationFactorLongitudes(seWrapper: seWrapper)  // Build error, TODO create test the same way as the others, there might be some overlap
        
        // Add more test helpers as needed...
        
        // Keep seWrapper alive until end of function
        _ = seWrapper
    }
}
