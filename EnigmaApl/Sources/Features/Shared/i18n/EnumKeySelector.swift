// EnumKeySelector.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Central access point for enum localization keys.
/// Use this selector to retrieve a localization key for any supported enum value.
struct EnumKeySelector {
    private init() {}

    static func key(for aspect: Aspects) -> String           { AspectKeys.key(for: aspect) }
    static func key(for ayanamsha: Ayanamshas) -> String     { AyanamshaKeys.key(for: ayanamsha) }
    static func key(for style: CalendarStyle) -> String      { CalendarStyleKeys.key(for: style) }
    static func key(for system: CoordinateSystems) -> String { CoordinateSystemKeys.key(for: system) }
    static func key(for option: DSTOption) -> String         { DSTOptionKeys.key(for: option) }
    static func key(for factor: Factors) -> String           { FactorKeys.key(for: factor) }
    static func key(for system: HouseSystems) -> String      { HouseSystemKeys.key(for: system) }
    static func key(for hemisphere: LatitudeHemisphere) -> String  { LatitudeHemisphereKeys.key(for: hemisphere) }
    static func key(for hemisphere: LongitudeHemisphere) -> String { LongitudeHemisphereKeys.key(for: hemisphere) }
    static func key(for position: ObserverPositions) -> String     { ObserverPositionKeys.key(for: position) }
    static func key(for type: ProjectionTypes) -> String     { ProjectionTypeKeys.key(for: type) }
    static func key(for rating: RoddenRating) -> String      { RoddenRatingKeys.key(for: rating) }
    static func key(for direction: UTOffsetDirection) -> String    { UTOffsetDirectionKeys.key(for: direction) }
    static func key(for count: YearCount) -> String          { YearCountKeys.key(for: count) }
    static func key(for type: ZodiacTypes) -> String         { ZodiacTypeKeys.key(for: type) }
}
