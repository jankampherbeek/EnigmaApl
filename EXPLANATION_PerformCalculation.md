# How `PerformCalculation` Works - Explanation

## Overview
The `PerformCalculation` method uses a **"group by type, then process"** pattern instead of a traditional loop with conditions. This is more efficient and maintainable.

## The Pattern

### Step 1: Group Factors by Calculation Type (Line 25)
```swift
let factorsByType = Dictionary(grouping: request.FactorsToUse) { $0.calculationType }
```

**What this does:**
- Takes all factors from `request.FactorsToUse` (e.g., `[.sun, .moon, .mercury, .persephoneRam, .priapus]`)
- Groups them by their `calculationType` property
- Creates a dictionary like:
  ```swift
  [
    .CommonSe: [.sun, .moon, .mercury],
    .CommonElements: [.persephoneRam],
    .CommonFormulaFull: [.priapus]
  ]
  ```

### Step 2: Process Each Group (Lines 32-107)
Instead of looping through all factors and checking each one's type, the code processes each **group**:

```swift
if let commonSeFactors = factorsByType[.CommonSe], !commonSeFactors.isEmpty {
    // Process all CommonSe factors at once
    let (commonSeCoordinates, calculatedObliquity) = SECalculation.CalculateFactors(commonSeRequest)
    allCoordinates.merge(commonSeCoordinates) { (_, new) in new }
}
```

**Why this pattern?**
- ✅ More efficient: factors of the same type are calculated together in batches
- ✅ Cleaner code: no need for switch statements or if-else chains
- ✅ Easier to maintain: each calculation type has its own method

## Where Are The Loops?

The loops that iterate over **individual factors** are inside the specialized calculation methods:

### Example: `SECalculation.CalculateFactors` (Line 26)
```swift
public static func CalculateFactors(_ request: SERequest) -> ([Factors: FullFactorPosition], Double) {
    var coordinates: [Factors: FullFactorPosition] = [:]
    
    // HERE'S THE LOOP! 👇
    for factor in request.FactorsToUse {
        let factorId = factor.seId
        
        // Calculate ecliptical position
        let eclipticalPos = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: factorId,
            flags: eclipticalFlags
        )
        
        // ... more calculations for this factor ...
        
        coordinates[factor] = fullPosition
    }
    
    return (coordinates, obliquity)
}
```

### Example: `FormulaFullCalc.CalculateFormulaFullFactors` (Line ~40)
```swift
public func CalculateFormulaFullFactors(...) -> [Factors: FullFactorPosition] {
    var coordinates: [Factors: FullFactorPosition] = [:]
    
    // HERE'S ANOTHER LOOP! 👇
    for factor in seRequest.FactorsToUse {
        switch factor {
        case .priapus, .priapusCorrected:
            // Calculate priapus...
        case .dragon, .beast:
            // Calculate dragon/beast...
        // ... etc
        }
    }
    
    return coordinates
}
```

## Visual Flow

```
PerformCalculation(request)
    │
    ├─> Step 1: Group factors by type
    │   └─> factorsByType = {
    │       .CommonSe: [.sun, .moon, .mercury],
    │       .CommonFormulaFull: [.priapus, .dragon]
    │   }
    │
    ├─> Step 2: Process .CommonSe group
    │   └─> SECalculation.CalculateFactors(commonSeRequest)
    │       └─> LOOP: for factor in [.sun, .moon, .mercury] {
    │           └─> Calculate position for each factor
    │       }
    │
    ├─> Step 3: Process .CommonFormulaFull group
    │   └─> FormulaFullCalc.CalculateFormulaFullFactors(...)
    │       └─> LOOP: for factor in [.priapus, .dragon] {
    │           └─> Calculate position for each factor
    │       }
    │
    └─> Step 4: Merge all results
        └─> return FullChart(coordinates: allCoordinates, ...)
```

## Alternative Pattern (What You Might Expect)

You might expect something like this:
```swift
for factor in request.FactorsToUse {
    switch factor.calculationType {
    case .CommonSe:
        // calculate CommonSe
    case .CommonElements:
        // calculate CommonElements
    // ... etc
    }
}
```

**Why the current pattern is better:**
- The alternative would check the type of **every single factor** individually
- The current pattern groups first, then processes each group once
- Each calculation method can optimize for its specific type

## Summary

✅ **The loops ARE there** - they're just inside the specialized calculation methods  
✅ **The conditions ARE there** - they're the `if let` checks for each calculation type  
✅ **The pattern is more efficient** - it groups first, then processes batches

The orchestrator is like a **conductor** that organizes the work, then delegates to specialized **musicians** (calculation methods) who each handle their own group of factors.

