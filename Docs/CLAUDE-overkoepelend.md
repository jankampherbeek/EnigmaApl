# Enigma — overkoepelende instructies (Mac + Windows)

Deze map bevat twee functioneel identieke versies van dezelfde astrologie-applicatie:

| Map           | Platform | Taal / UI       | Patroon                         | i18n                              | Git-branch |
|---------------|----------|-----------------|---------------------------------|-----------------------------------|------------|
| `EnigmaApl/`  | macOS    | Swift / SwiftUI | **VM** (`*Model`, geen `*ViewModel`) | `.strings` + `t()` + `<Feature>Keys` | `main`     |
| `EnigmaWin/`  | Windows  | C# / WPF        | **MVVM** (CommunityToolkit, `*ViewModel`) | Rosetta                           | `master`   |

Elk project heeft een eigen `CLAUDE.md` met de gedetailleerde conventies. **Lees altijd eerst de `CLAUDE.md` van het project waarin je werkt** en pas alleen díe conventies toe. Meng nooit conventies van het ene project in het andere.

## Werkafspraken

- Benoem bij elke taak expliciet welk project (of beide) je bewerkt.
- EnigmaApl is het referentieproject: nieuwe features en domeinlogica ontstaan daar meestal eerst en worden daarna naar EnigmaWin geport.
- Bij porten: vertaal SwiftUI-views + `*Model` naar WPF XAML-views + `*ViewModel`. Domeinlogica en berekeningen moeten inhoudelijk identiek blijven (zelfde resultaten, zelfde i18n-sleutels waar mogelijk).
- Wijzigingen in domeinlogica of berekeningen in het ene project: wijs erop als het andere project dezelfde aanpassing nodig heeft.
- Git: elk project is een aparte repository. Commit per repository afzonderlijk.
- EnigmaWin wordt **niet** via git gesynchroniseerd met EnigmaApl, maar bijgewerkt door de Apple-versie te vergelijken en te porten. Er is één werkmap: beide projecten staan op deze Mac-schijf, en Windows (Parallels-VM) werkt rechtstreeks op dezelfde bestanden.

## Bouwen en testen

- **EnigmaApl** kan op deze Mac gebouwd en getest worden.
- **EnigmaWin** (WPF, `net10.0-windows`, x64) kan op macOS niet gebouwd worden, maar wel vanaf de Mac in de Windows-VM (Parallels, ARM64). De VM moet draaien en de gebruiker moet in Windows ingelogd zijn. `~/Development` is in Windows bereikbaar als `Z:\Development`.

  ```bash
  # Build
  prlctl exec "Windows 11 (1)" --current-user cmd /c "cd /d Z:\Development\EnigmaWin && dotnet build EnigmaWin.sln -nologo -v q"
  # Tests (--arch x64 is verplicht: het project is x64, Windows draait ARM64)
  prlctl exec "Windows 11 (1)" --current-user cmd /c "cd /d Z:\Development\EnigmaWin && dotnet test EnigmaWinTest\EnigmaWinTest.csproj --arch x64 -nologo -v q"
  ```

  Werkt `prlctl exec` niet (hangt of `PRL_ERR_IO_STOPPED`)? Controleer eerst met `prlctl list -i "Windows 11 (1)" | grep State` of de VM gepauzeerd is; Parallels pauzeert hem automatisch bij inactiviteit. Hervat dan met `prlctl resume "Windows 11 (1)"`. Helpt dat niet, vraag de gebruiker dan om in Windows in te loggen. De GUI van de app kan ik niet zelf bekijken; vraag de gebruiker om visuele wijzigingen te controleren.

## Line endings

EnigmaWin-bestanden gebruiken CRLF. Behoud bij bewerken de bestaande line endings.

## Overige mappen

- `factsheets/` — HTML/CSS voor factsheets
- `notes/` — notities, referentiedata en documentatie
- `se/` — Swiss Ephemeris code en data
- `secode/` — Swiss Ephemeris broncode / gecompileerde bibliotheek (`libswe.a`)
