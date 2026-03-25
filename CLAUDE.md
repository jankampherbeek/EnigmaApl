# EnigmaApl — instructies voor Claude

## Architectuur

Dit project gebruikt het **VM-patroon (View - Model)**, niet MVVM.
- Gebruik geen ViewModels met naam `*ViewModel` tenzij die al bestaan.
- Een `*Model`-klasse of -struct fungeert direct als het model voor de bijbehorende `*Screen`- of `*View`.

## Teksten en i18n

Alle teksten die aan de gebruiker worden getoond worden **altijd** via i18n opgehaald — nooit hardcoded in een view.

### Werking

Elke feature heeft een eigen `.strings`-tabel (bijv. `RadixChart.strings`, `RadixPositions.strings`). Views gebruiken een lokale `t()`-helperfunctie om sleutels op te zoeken:

```swift
private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "RadixChart", bundle: .main, comment: "")
}
```

Sleutelnamen worden gedefinieerd als statische constanten in een keys-struct in `Sources/Features/Shared/i18n/`, bijv.:

```swift
struct RadixChartKeys {
    private init() {}
    static let noChartTitle = "view.horoscopescreen.nochart.title"
}
```

In de view wordt dan `Text(t(RadixChartKeys.noChartTitle))` gebruikt.

### Naamgevingsconventies

- Sleutels voor schermteksten: `view.<screennaam>.<beschrijving>` (bijv. `view.horoscopescreen.nochart.title`)
- Sleutels voor enum-waarden: `enum.<enumtype>.<waarde>` (bijv. `enum.drawingtype.signbased`) — deze staan in `Localizable.strings` en worden via de `rbKey`-property van de enum teruggegeven
- Keys-structs heten `<Feature>Keys` (bijv. `RadixChartKeys`, `RadixOverviewKeys`)
- `.strings`-bestanden heten naar de feature, niet naar het scherm (bijv. `RadixChart.strings`)

### Bij elke nieuwe view

1. Maak een `<Feature>.strings` aan in alle 4 lproj-mappen (`nl`, `en`, `de`, `fr`)
2. Maak een `<Feature>Keys.swift` aan in `Sources/Features/Shared/i18n/`
3. Voeg een `t()`-functie toe aan de view
4. Gebruik `Text(t(<FeatureKeys>.someKey))` in de view

## Bestandsheader / copyright

Elk nieuw Swift-bronbestand begint met de volgende commentaarregel (na eventuele Xcode-gegenereerde regels):

```swift
// [bestandsnaam]
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek [jaar]
```

- Vervang `[bestandsnaam]` door de werkelijke bestandsnaam (inclusief `.swift`).
- Vervang `[jaar]` door het actuele jaar op het moment van aanmaken.
- Elke zin staat op een aparte regel.
- Vervang bestaande copyright- of Xcode-gegenereerde headerregels volledig door dit blok.
