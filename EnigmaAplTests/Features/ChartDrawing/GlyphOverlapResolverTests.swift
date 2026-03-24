//
//  GlyphOverlapResolverTests.swift
//  EnigmaAplTests
//

import Testing
@testable import EnigmaApl

struct GlyphOverlapResolverTests {

    // MARK: - Hulpfunctie

    private func makeItem(factor: Factors = .sun, mundaneAngle: Double, plotAngle: Double? = nil) -> WheelPlotItem {
        WheelPlotItem(
            factor: factor,
            glyph: "A",
            eclipticLongitude: 0,
            mundaneAngle: mundaneAngle,
            plotAngle: plotAngle ?? mundaneAngle,
            positionText: "0°00'"
        )
    }

    // MARK: - Randgevallen

    @Test("resolve: lege array geeft lege array terug")
    func testResolveEmpty() {
        let result = GlyphOverlapResolver.resolve([])
        #expect(result.isEmpty)
    }

    @Test("resolve: één item blijft ongewijzigd")
    func testResolveSingleItem() {
        let item = makeItem(mundaneAngle: 45)
        let result = GlyphOverlapResolver.resolve([item])
        #expect(result.count == 1)
        #expect(result[0].plotAngle == 45.0)
    }

    // MARK: - Geen overlap

    @Test("resolve: twee items met voldoende afstand (> 6°) blijven ongewijzigd")
    func testResolveNoOverlap() {
        let item1 = makeItem(factor: .sun,  mundaneAngle: 10)
        let item2 = makeItem(factor: .moon, mundaneAngle: 20)
        let result = GlyphOverlapResolver.resolve([item1, item2])
        #expect(result.count == 2)
        #expect(result[0].plotAngle == 10.0)
        #expect(result[1].plotAngle == 20.0)
    }

    @Test("resolve: twee items met exact 6° afstand blijven ongewijzigd")
    func testResolveExactMinDistance() {
        let item1 = makeItem(factor: .sun,  mundaneAngle: 10)
        let item2 = makeItem(factor: .moon, mundaneAngle: 16)
        let result = GlyphOverlapResolver.resolve([item1, item2])
        #expect(result[0].plotAngle == 10.0)
        #expect(result[1].plotAngle == 16.0)
    }

    // MARK: - Overlap oplossen

    @Test("resolve: twee overlappende items worden symmetrisch uit elkaar geschoven")
    func testResolveTwoOverlapping() {
        let item1 = makeItem(factor: .sun,  mundaneAngle: 10)
        let item2 = makeItem(factor: .moon, mundaneAngle: 13)  // 3° verschil, < 6°
        let result = GlyphOverlapResolver.resolve([item1, item2])
        // Na correctie moeten beide minstens 6° van elkaar af zitten
        let sorted = result.sorted { $0.plotAngle < $1.plotAngle }
        let diff = sorted[1].plotAngle - sorted[0].plotAngle
        #expect(diff >= 6.0 - 1e-10)
    }

    @Test("resolve: twee items op identieke hoek worden 6° uit elkaar geplaatst")
    func testResolveSameAngle() {
        let item1 = makeItem(factor: .sun,  mundaneAngle: 50)
        let item2 = makeItem(factor: .moon, mundaneAngle: 50)
        let result = GlyphOverlapResolver.resolve([item1, item2])
        let sorted = result.sorted { $0.plotAngle < $1.plotAngle }
        let diff = sorted[1].plotAngle - sorted[0].plotAngle
        #expect(diff >= 6.0 - 1e-10)
    }

    @Test("resolve: mundaneAngle van items blijft ongewijzigd, alleen plotAngle verandert")
    func testResolveMundaneAngleUnchanged() {
        let item1 = makeItem(factor: .sun,  mundaneAngle: 10)
        let item2 = makeItem(factor: .moon, mundaneAngle: 13)
        let result = GlyphOverlapResolver.resolve([item1, item2])
        let angles = Set(result.map { $0.mundaneAngle })
        #expect(angles.contains(10.0))
        #expect(angles.contains(13.0))
    }

    // MARK: - Sortering

    @Test("resolve: uitvoer is gesorteerd op mundaneAngle")
    func testResolveSortedOutput() {
        let item1 = makeItem(factor: .sun,     mundaneAngle: 80)
        let item2 = makeItem(factor: .moon,    mundaneAngle: 10)
        let item3 = makeItem(factor: .mercury, mundaneAngle: 45)
        let result = GlyphOverlapResolver.resolve([item1, item2, item3])
        #expect(result[0].mundaneAngle < result[1].mundaneAngle)
        #expect(result[1].mundaneAngle < result[2].mundaneAngle)
    }
}
