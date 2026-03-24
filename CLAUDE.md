# EnigmaApl — instructies voor Claude

## Architectuur

Dit project gebruikt het **VM-patroon (View - Model)**, niet MVVM.
- Gebruik geen ViewModels met naam `*ViewModel` tenzij die al bestaan.
- Een `*Model`-klasse of -struct fungeert direct als het model voor de bijbehorende `*Screen`- of `*View`.
