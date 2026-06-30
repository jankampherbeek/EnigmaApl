// StarDefinitions.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Indicates membership of a fixed star in the Ptolemy, Robson and Brady selection lists.
struct StarSelectionMembership {
    let inPtolemy: Bool
    let inRobson: Bool
    let inBrady: Bool
}

/// All named fixed stars available in sefstars.txt.
public enum StarDefinitions: Codable, CaseIterable {

    case aldebaran
    case algol
    case antares
    case regulus
    case sirius
    case spica
    case galCenter
    case greatAttractor
    case virgoCluster
    case andromedaGalaxy
    case praesepeCluster
    case polaris
    case sanduleak
    case deneb
    case rigel
    case mira
    case ain
    case segin
    case alpheratz
    case mirach
    case almaak
    case adhil
    case adhab
    case altair
    case alshain
    case tarazed
    case alMizan
    case denebElOkabBorealis
    case denebElOkabAustralis
    case bazak
    case tseenFoo
    case alThalimaimPosterior
    case alThalimaimAnterior
    case bered
    case sadalmelek
    case sadalsuud
    case sadalachbia
    case skat
    case albali
    case sadaltager
    case hydria
    case ancha
    case situla
    case hydor
    case albulaan
    case seat
    case bunda
    case ara
    case hamal
    case sheratan
    case mesarthim
    case botein
    case capella
    case menkalinan
    case prijipati
    case maaz
    case haedi
    case hoedusIi
    case bogardus
    case hasseleh
    case arcturus
    case nekkar
    case seginus
    case princeps
    case izar
    case mufrid
    case asellusPrimus
    case asellusSecundus
    case asellusTertius
    case alkalurops
    case hemeleinPrima
    case hemeleinSecunda
    case ceginus
    case merga
    case algedi1
    case algedi2
    case dabih
    case nashira
    case denebAlgedi
    case castra
    case marakk
    case armus
    case dorsum
    case alshat
    case oculus
    case bos
    case pazan
    case batenAlgiedi
    case canopus
    case miaplacidus
    case avior
    case foramen
    case vathorzPosterior
    case scutulum
    case drus
    case simiram
    case vathorzPrior
    case schedar
    case caph
    case tsih
    case ruchbah
    case achird
    case marfak
    case rigilKent
    case hadar
    case muhlifain
    case birdun
    case menkent
    case alhakim
    case keKwan
    case maTi
    case kabkentSecunda
    case kabkentTertia
    case proximaCentauri
    case alderamin
    case alphirk
    case alrai
    case alradif
    case phicares
    case kurhah
    case alagemin
    case alkidr
    case alvahet
    case erakis
    case kurdah
    case alKalbAlRai
    case menkar1
    case diphda
    case kaffaljidhma
    case phycochroma
    case batenKaitos
    case denebAlgenubi
    case altawk
    case denebKaitos
    case menkar2
    case alSadrAlKetus
    case abyssusAqueus
    case alNitham
    case mirzam
    case muliphein
    case wezen
    case adara
    case furud
    case aludra
    case procyon
    case gomeisa
    case acubens
    case alTarf
    case asellusBorealis
    case asellusAustralis
    case tegmen
    case decapoda
    case phact
    case wazn
    case ghusnAlZaitun
    case alKurud
    case tsze
    case diadem
    case aldafirah
    case kissin
    case alphecca
    case nusakan
    case theBlazeStar
    case alfeccaMeridiana
    case alkes
    case alsharasif
    case labrum
    case acrux
    case mimosa
    case gacrux
    case decrux
    case juxtaCrucem
    case alchiba
    case kraz
    case gienahCorvi
    case algorab
    case minkar
    case avisSatyra
    case corCaroli
    case asterion
    case albireo
    case sador
    case ruc
    case gienahCygni
    case azelfafage
    case ruchbahI
    case ruchbahIi
    case sualocin
    case rotanev
    case denebDulphim
    case thuban
    case alwaid
    case eltanin
    case nodusIi
    case tyl
    case nodusI
    case alsafi1
    case edasich
    case ketu
    case giansar
    case arrakis
    case kuma1
    case kuma2
    case grumium
    case alsafi2
    case batentabanBorealis
    case dziban
    case alathfar1
    case aldhibain
    case batentabanAustralis
    case kitalpha
    case achernar
    case cursa
    case zaurak
    case rana
    case azha
    case acamar
    case zibal
    case beid
    case keid
    case angetenar
    case theemin
    case sceptrum
    case fornacis
    case castor
    case pollux
    case alhena
    case wasat
    case mebsuta
    case mekbuda
    case propusEtagem
    case nageba
    case propusIotgem
    case alKrikab
    case kebash
    case tejat
    case alzirr
    case alnair
    case gruid
    case alDhanab
    case rasAlgethi
    case kornephoros
    case rutilicus
    case sarin
    case kajamEpsher
    case sofian
    case rukbalgethiGenubi
    case alJathiyah
    case marsik
    case masym
    case melkarth
    case fudail
    case rukbalgethiShemali
    case kajamOmeher
    case apex
    case alphard
    case caudaHydrae
    case mautinah
    case ashlesha
    case hydrobius
    case pleura
    case sataghni
    case alMinliarAlShuja
    case ukdah1
    case ukdah2
    case denebola
    case algieba1
    case dhur
    case rasElasedAustralis
    case adhafera
    case algieba2
    case tseTseng
    case alminhar
    case alterf
    case rasElasedBorealis
    case subra
    case shishimai
    case coxa
    case shir
    case arneb
    case nihal
    case sasin
    case zubenelgenubi
    case zubeneshamali
    case zubenelakrab
    case zubenelakribi
    case zubenhakrabi
    case brachium
    case praecipua
    case kakkab
    case kekouan
    case thusia
    case hilasmus
    case alvashak
    case alsciaukat
    case mabsuthat
    case maculosa
    case vega
    case sheliak
    case sulaphat
    case aladfar
    case alathfar2
    case polarisAustralis
    case rasalhague
    case celbalrai
    case alDurajah
    case yedPrior
    case yedPosterior
    case han
    case sabik
    case imad
    case helkath
    case marfik
    case sinistra
    case barnardsStar
    case betelgeuse
    case bellatrix
    case mintaka
    case alnilam
    case alnitak
    case trapezium
    case hatsya
    case saiph
    case heka
    case tabit1
    case tabit2
    case thabit
    case peacock
    case ankaa
    case markab
    case scheat
    case algenib
    case enif
    case homam
    case matar
    case biham
    case jih
    case sadalbari
    case kerb
    case mirfak
    case atik
    case miram
    case misam
    case menkib
    case atiks
    case gorgonaSecunda
    case gorgonaTertia
    case gorgonaQuatra
    case capulus1
    case capulus2
    case fomalhaut
    case tienKang
    case aboras
    case alrischa
    case fumAlsamakah
    case simmah
    case linteum
    case kaht
    case alPherg
    case torcularisSeptentrionalis
    case anunitum
    case vernalis
    case naos
    case kaimana
    case azmidiske
    case ahadi
    case turais
    case alRihla
    case graffias
    case aculeus
    case acumen
    case dschubba
    case wei
    case sargas
    case girtab
    case shaula
    case jabbah
    case grafias
    case alniyat
    case lesath
    case jabhatAlAkrab1
    case jabhatAlAkrab2
    case unukalhai
    case chow
    case ainalhai
    case qin
    case nullaPambu
    case tang
    case alya
    case leiolepis
    case nehushtan
    case sham
    case rukbat
    case arkabPrior
    case arkabPosterior
    case alnasl
    case kausMedis
    case kausAustralis
    case ascella
    case sephdar
    case kausBorealis
    case polis
    case ainAlRami
    case manubrium
    case albaldah
    case nunki
    case hecatebolus
    case nanto
    case terebellium
    case facies
    case spiculum
    case elnath
    case primaHyadum
    case secundaHyadum
    case alHecka
    case alcyone
    case phaeo
    case phaesula
    case althaur
    case kattupothu
    case furibundus
    case ushakaron
    case atirsagne
    case celeano
    case electra
    case taygeta
    case maia
    case asterope
    case steropeIi
    case merope
    case atlas
    case pleione
    case atria
    case rasMutallah
    case dubhe
    case merak
    case phecda
    case megrez
    case alioth
    case mizar
    case alkaid
    case alHaud
    case talithaBorealis
    case talithaAustralis
    case taniaBorealis
    case taniaAustralis
    case alulaBorealis
    case alulaAustralis
    case muscida
    case elKophrah
    case alcor
    case kochab
    case pherkad
    case yildun
    case urodelus
    case alifaAlFarkadain
    case anwarAlFarkadain
    case pherkadMinor
    case suhailAlMuhlif
    case kooShe
    case markeb
    case alsuhail
    case peregrini
    case xestus
    case tseenKe
    case zavijava
    case porrima
    case auva
    case vindemiatrix
    case heze
    case zaniah
    case syrma
    case khambalia
    case rijlAlAwwa
    case anser

    var name: String {
        switch self {
        case .aldebaran: return "Aldebaran"
        case .algol: return "Algol"
        case .antares: return "Antares"
        case .regulus: return "Regulus"
        case .sirius: return "Sirius"
        case .spica: return "Spica"
        case .galCenter: return "Gal. Center"
        case .greatAttractor: return "Great Attractor"
        case .virgoCluster: return "Virgo Cluster"
        case .andromedaGalaxy: return "Andromeda Galaxy"
        case .praesepeCluster: return "Praesepe Cluster"
        case .polaris: return "Polaris"
        case .sanduleak: return "Sanduleak"
        case .deneb: return "Deneb"
        case .rigel: return "Rigel"
        case .mira: return "Mira"
        case .ain: return "Ain"
        case .segin: return "Segin"
        case .alpheratz: return "Alpheratz"
        case .mirach: return "Mirach"
        case .almaak: return "Almaak"
        case .adhil: return "Adhil"
        case .adhab: return "Adhab"
        case .altair: return "Altair"
        case .alshain: return "Alshain"
        case .tarazed: return "Tarazed"
        case .alMizan: return "Al Mizan"
        case .denebElOkabBorealis: return "Deneb el Okab Borealis"
        case .denebElOkabAustralis: return "Deneb el Okab Australis"
        case .bazak: return "Bazak"
        case .tseenFoo: return "Tseen Foo"
        case .alThalimaimPosterior: return "Al Thalimaim Posterior"
        case .alThalimaimAnterior: return "Al Thalimaim Anterior"
        case .bered: return "Bered"
        case .sadalmelek: return "Sadalmelek"
        case .sadalsuud: return "Sadalsuud"
        case .sadalachbia: return "Sadalachbia"
        case .skat: return "Skat"
        case .albali: return "Albali"
        case .sadaltager: return "Sadaltager"
        case .hydria: return "Hydria"
        case .ancha: return "Ancha"
        case .situla: return "Situla"
        case .hydor: return "Hydor"
        case .albulaan: return "Albulaan"
        case .seat: return "Seat"
        case .bunda: return "Bunda"
        case .ara: return "Ara"
        case .hamal: return "Hamal"
        case .sheratan: return "Sheratan"
        case .mesarthim: return "Mesarthim"
        case .botein: return "Botein"
        case .capella: return "Capella"
        case .menkalinan: return "Menkalinan"
        case .prijipati: return "Prijipati"
        case .maaz: return "Maaz"
        case .haedi: return "Haedi"
        case .hoedusIi: return "Hoedus II"
        case .bogardus: return "Bogardus"
        case .hasseleh: return "Hasseleh"
        case .arcturus: return "Arcturus"
        case .nekkar: return "Nekkar"
        case .seginus: return "Seginus"
        case .princeps: return "Princeps"
        case .izar: return "Izar"
        case .mufrid: return "Mufrid"
        case .asellusPrimus: return "Asellus Primus"
        case .asellusSecundus: return "Asellus Secundus"
        case .asellusTertius: return "Asellus Tertius"
        case .alkalurops: return "Alkalurops"
        case .hemeleinPrima: return "Hemelein Prima"
        case .hemeleinSecunda: return "Hemelein Secunda"
        case .ceginus: return "Ceginus"
        case .merga: return "Merga"
        case .algedi1: return "Algedi"
        case .algedi2: return "Algedi"
        case .dabih: return "Dabih"
        case .nashira: return "Nashira"
        case .denebAlgedi: return "Deneb Algedi"
        case .castra: return "Castra"
        case .marakk: return "Marakk"
        case .armus: return "Armus"
        case .dorsum: return "Dorsum"
        case .alshat: return "Alshat"
        case .oculus: return "Oculus"
        case .bos: return "Bos"
        case .pazan: return "Pazan"
        case .batenAlgiedi: return "Baten Algiedi"
        case .canopus: return "Canopus"
        case .miaplacidus: return "Miaplacidus"
        case .avior: return "Avior"
        case .foramen: return "Foramen"
        case .vathorzPosterior: return "Vathorz Posterior"
        case .scutulum: return "Scutulum"
        case .drus: return "Drus"
        case .simiram: return "Simiram"
        case .vathorzPrior: return "Vathorz Prior"
        case .schedar: return "Schedar"
        case .caph: return "Caph"
        case .tsih: return "Tsih"
        case .ruchbah: return "Ruchbah"
        case .achird: return "Achird"
        case .marfak: return "Marfak"
        case .rigilKent: return "Rigil Kent"
        case .hadar: return "Hadar"
        case .muhlifain: return "Muhlifain"
        case .birdun: return "Birdun"
        case .menkent: return "Menkent"
        case .alhakim: return "Alhakim"
        case .keKwan: return "Ke Kwan"
        case .maTi: return "Ma Ti"
        case .kabkentSecunda: return "Kabkent Secunda"
        case .kabkentTertia: return "Kabkent Tertia"
        case .proximaCentauri: return "Proxima Centauri"
        case .alderamin: return "Alderamin"
        case .alphirk: return "Alphirk"
        case .alrai: return "Alrai"
        case .alradif: return "Alradif"
        case .phicares: return "Phicares"
        case .kurhah: return "Kurhah"
        case .alagemin: return "Alagemin"
        case .alkidr: return "Alkidr"
        case .alvahet: return "Alvahet"
        case .erakis: return "Erakis"
        case .kurdah: return "Kurdah"
        case .alKalbAlRai: return "Al Kalb al Rai"
        case .menkar1: return "Menkar"
        case .diphda: return "Diphda"
        case .kaffaljidhma: return "Kaffaljidhma"
        case .phycochroma: return "Phycochroma"
        case .batenKaitos: return "Baten Kaitos"
        case .denebAlgenubi: return "Deneb Algenubi"
        case .altawk: return "Altawk"
        case .denebKaitos: return "Deneb Kaitos"
        case .menkar2: return "Menkar"
        case .alSadrAlKetus: return "Al Sadr al Ketus"
        case .abyssusAqueus: return "Abyssus Aqueus"
        case .alNitham: return "Al Nitham"
        case .mirzam: return "Mirzam"
        case .muliphein: return "Muliphein"
        case .wezen: return "Wezen"
        case .adara: return "Adara"
        case .furud: return "Furud"
        case .aludra: return "Aludra"
        case .procyon: return "Procyon"
        case .gomeisa: return "Gomeisa"
        case .acubens: return "Acubens"
        case .alTarf: return "Al Tarf"
        case .asellusBorealis: return "Asellus Borealis"
        case .asellusAustralis: return "Asellus Australis"
        case .tegmen: return "Tegmen"
        case .decapoda: return "Decapoda"
        case .phact: return "Phact"
        case .wazn: return "Wazn"
        case .ghusnAlZaitun: return "Ghusn al Zaitun"
        case .alKurud: return "Al Kurud"
        case .tsze: return "Tsze"
        case .diadem: return "Diadem"
        case .aldafirah: return "Aldafirah"
        case .kissin: return "Kissin"
        case .alphecca: return "Alphecca"
        case .nusakan: return "Nusakan"
        case .theBlazeStar: return "The Blaze Star"
        case .alfeccaMeridiana: return "Alfecca Meridiana"
        case .alkes: return "Alkes"
        case .alsharasif: return "Alsharasif"
        case .labrum: return "Labrum"
        case .acrux: return "Acrux"
        case .mimosa: return "Mimosa"
        case .gacrux: return "Gacrux"
        case .decrux: return "Decrux"
        case .juxtaCrucem: return "Juxta Crucem"
        case .alchiba: return "Alchiba"
        case .kraz: return "Kraz"
        case .gienahCorvi: return "Gienah Corvi"
        case .algorab: return "Algorab"
        case .minkar: return "Minkar"
        case .avisSatyra: return "Avis Satyra"
        case .corCaroli: return "Cor Caroli"
        case .asterion: return "Asterion"
        case .albireo: return "Albireo"
        case .sador: return "Sador"
        case .ruc: return "Ruc"
        case .gienahCygni: return "Gienah Cygni"
        case .azelfafage: return "Azelfafage"
        case .ruchbahI: return "Ruchbah I"
        case .ruchbahIi: return "Ruchbah II"
        case .sualocin: return "Sualocin"
        case .rotanev: return "Rotanev"
        case .denebDulphim: return "Deneb Dulphim"
        case .thuban: return "Thuban"
        case .alwaid: return "Alwaid"
        case .eltanin: return "Eltanin"
        case .nodusIi: return "Nodus II"
        case .tyl: return "Tyl"
        case .nodusI: return "Nodus I"
        case .alsafi1: return "Alsafi"
        case .edasich: return "Edasich"
        case .ketu: return "Ketu"
        case .giansar: return "Giansar"
        case .arrakis: return "Arrakis"
        case .kuma1: return "Kuma"
        case .kuma2: return "Kuma"
        case .grumium: return "Grumium"
        case .alsafi2: return "Alsafi"
        case .batentabanBorealis: return "Batentaban Borealis"
        case .dziban: return "Dziban"
        case .alathfar1: return "Alathfar"
        case .aldhibain: return "Aldhibain"
        case .batentabanAustralis: return "Batentaban Australis"
        case .kitalpha: return "Kitalpha"
        case .achernar: return "Achernar"
        case .cursa: return "Cursa"
        case .zaurak: return "Zaurak"
        case .rana: return "Rana"
        case .azha: return "Azha"
        case .acamar: return "Acamar"
        case .zibal: return "Zibal"
        case .beid: return "Beid"
        case .keid: return "Keid"
        case .angetenar: return "Angetenar"
        case .theemin: return "Theemin"
        case .sceptrum: return "Sceptrum"
        case .fornacis: return "Fornacis"
        case .castor: return "Castor"
        case .pollux: return "Pollux"
        case .alhena: return "Alhena"
        case .wasat: return "Wasat"
        case .mebsuta: return "Mebsuta"
        case .mekbuda: return "Mekbuda"
        case .propusEtagem: return "Propus etaGem"
        case .nageba: return "Nageba"
        case .propusIotgem: return "Propus iotGem"
        case .alKrikab: return "Al Krikab"
        case .kebash: return "Kebash"
        case .tejat: return "Tejat"
        case .alzirr: return "Alzirr"
        case .alnair: return "Alnair"
        case .gruid: return "Gruid"
        case .alDhanab: return "Al Dhanab"
        case .rasAlgethi: return "Ras Algethi"
        case .kornephoros: return "Kornephoros"
        case .rutilicus: return "Rutilicus"
        case .sarin: return "Sarin"
        case .kajamEpsher: return "Kajam epsHer"
        case .sofian: return "Sofian"
        case .rukbalgethiGenubi: return "Rukbalgethi Genubi"
        case .alJathiyah: return "Al Jathiyah"
        case .marsik: return "Marsik"
        case .masym: return "Masym"
        case .melkarth: return "Melkarth"
        case .fudail: return "Fudail"
        case .rukbalgethiShemali: return "Rukbalgethi Shemali"
        case .kajamOmeher: return "Kajam omeHer"
        case .apex: return "Apex"
        case .alphard: return "Alphard"
        case .caudaHydrae: return "Cauda Hydrae"
        case .mautinah: return "Mautinah"
        case .ashlesha: return "Ashlesha"
        case .hydrobius: return "Hydrobius"
        case .pleura: return "Pleura"
        case .sataghni: return "Sataghni"
        case .alMinliarAlShuja: return "Al Minliar al Shuja"
        case .ukdah1: return "Ukdah"
        case .ukdah2: return "Ukdah"
        case .denebola: return "Denebola"
        case .algieba1: return "Algieba"
        case .dhur: return "Dhur"
        case .rasElasedAustralis: return "Ras Elased Australis"
        case .adhafera: return "Adhafera"
        case .algieba2: return "Algieba"
        case .tseTseng: return "Tse Tseng"
        case .alminhar: return "Alminhar"
        case .alterf: return "Alterf"
        case .rasElasedBorealis: return "Ras Elased Borealis"
        case .subra: return "Subra"
        case .shishimai: return "Shishimai"
        case .coxa: return "Coxa"
        case .shir: return "Shir"
        case .arneb: return "Arneb"
        case .nihal: return "Nihal"
        case .sasin: return "Sasin"
        case .zubenelgenubi: return "Zubenelgenubi"
        case .zubeneshamali: return "Zubeneshamali"
        case .zubenelakrab: return "Zubenelakrab"
        case .zubenelakribi: return "Zubenelakribi"
        case .zubenhakrabi: return "Zubenhakrabi"
        case .brachium: return "Brachium"
        case .praecipua: return "Praecipua"
        case .kakkab: return "Kakkab"
        case .kekouan: return "Kekouan"
        case .thusia: return "Thusia"
        case .hilasmus: return "Hilasmus"
        case .alvashak: return "Alvashak"
        case .alsciaukat: return "Alsciaukat"
        case .mabsuthat: return "Mabsuthat"
        case .maculosa: return "Maculosa"
        case .vega: return "Vega"
        case .sheliak: return "Sheliak"
        case .sulaphat: return "Sulaphat"
        case .aladfar: return "Aladfar"
        case .alathfar2: return "Alathfar"
        case .polarisAustralis: return "Polaris Australis"
        case .rasalhague: return "Rasalhague"
        case .celbalrai: return "Celbalrai"
        case .alDurajah: return "Al Durajah"
        case .yedPrior: return "Yed Prior"
        case .yedPosterior: return "Yed Posterior"
        case .han: return "Han"
        case .sabik: return "Sabik"
        case .imad: return "Imad"
        case .helkath: return "Helkath"
        case .marfik: return "Marfik"
        case .sinistra: return "Sinistra"
        case .barnardsStar: return "Barnard's star"
        case .betelgeuse: return "Betelgeuse"
        case .bellatrix: return "Bellatrix"
        case .mintaka: return "Mintaka"
        case .alnilam: return "Alnilam"
        case .alnitak: return "Alnitak"
        case .trapezium: return "Trapezium"
        case .hatsya: return "Hatsya"
        case .saiph: return "Saiph"
        case .heka: return "Heka"
        case .tabit1: return "Tabit"
        case .tabit2: return "Tabit"
        case .thabit: return "Thabit"
        case .peacock: return "Peacock"
        case .ankaa: return "Ankaa"
        case .markab: return "Markab"
        case .scheat: return "Scheat"
        case .algenib: return "Algenib"
        case .enif: return "Enif"
        case .homam: return "Homam"
        case .matar: return "Matar"
        case .biham: return "Biham"
        case .jih: return "Jih"
        case .sadalbari: return "Sadalbari"
        case .kerb: return "Kerb"
        case .mirfak: return "Mirfak"
        case .atik: return "Atik"
        case .miram: return "Miram"
        case .misam: return "Misam"
        case .menkib: return "Menkib"
        case .atiks: return "Atiks"
        case .gorgonaSecunda: return "Gorgona Secunda"
        case .gorgonaTertia: return "Gorgona Tertia"
        case .gorgonaQuatra: return "Gorgona Quatra"
        case .capulus1: return "Capulus"
        case .capulus2: return "Capulus"
        case .fomalhaut: return "Fomalhaut"
        case .tienKang: return "Tien Kang"
        case .aboras: return "Aboras"
        case .alrischa: return "Alrischa"
        case .fumAlsamakah: return "Fum Alsamakah"
        case .simmah: return "Simmah"
        case .linteum: return "Linteum"
        case .kaht: return "Kaht"
        case .alPherg: return "Al Pherg"
        case .torcularisSeptentrionalis: return "Torcularis Septentrionalis"
        case .anunitum: return "Anunitum"
        case .vernalis: return "Vernalis"
        case .naos: return "Naos"
        case .kaimana: return "Kaimana"
        case .azmidiske: return "Azmidiske"
        case .ahadi: return "Ahadi"
        case .turais: return "Turais"
        case .alRihla: return "Al Rihla"
        case .graffias: return "Graffias"
        case .aculeus: return "Aculeus"
        case .acumen: return "Acumen"
        case .dschubba: return "Dschubba"
        case .wei: return "Wei"
        case .sargas: return "Sargas"
        case .girtab: return "Girtab"
        case .shaula: return "Shaula"
        case .jabbah: return "Jabbah"
        case .grafias: return "Grafias"
        case .alniyat: return "Alniyat"
        case .lesath: return "Lesath"
        case .jabhatAlAkrab1: return "Jabhat al Akrab"
        case .jabhatAlAkrab2: return "Jabhat al Akrab"
        case .unukalhai: return "Unukalhai"
        case .chow: return "Chow"
        case .ainalhai: return "Ainalhai"
        case .qin: return "Qin"
        case .nullaPambu: return "Nulla Pambu"
        case .tang: return "Tang"
        case .alya: return "Alya"
        case .leiolepis: return "Leiolepis"
        case .nehushtan: return "Nehushtan"
        case .sham: return "Sham"
        case .rukbat: return "Rukbat"
        case .arkabPrior: return "Arkab Prior"
        case .arkabPosterior: return "Arkab Posterior"
        case .alnasl: return "Alnasl"
        case .kausMedis: return "Kaus Medis"
        case .kausAustralis: return "Kaus Australis"
        case .ascella: return "Ascella"
        case .sephdar: return "Sephdar"
        case .kausBorealis: return "Kaus Borealis"
        case .polis: return "Polis"
        case .ainAlRami: return "Ain al Rami"
        case .manubrium: return "Manubrium"
        case .albaldah: return "Albaldah"
        case .nunki: return "Nunki"
        case .hecatebolus: return "Hecatebolus"
        case .nanto: return "Nanto"
        case .terebellium: return "Terebellium"
        case .facies: return "Facies"
        case .spiculum: return "Spiculum"
        case .elnath: return "Elnath"
        case .primaHyadum: return "Prima Hyadum"
        case .secundaHyadum: return "Secunda Hyadum"
        case .alHecka: return "Al Hecka"
        case .alcyone: return "Alcyone"
        case .phaeo: return "Phaeo"
        case .phaesula: return "Phaesula"
        case .althaur: return "Althaur"
        case .kattupothu: return "Kattupothu"
        case .furibundus: return "Furibundus"
        case .ushakaron: return "Ushakaron"
        case .atirsagne: return "Atirsagne"
        case .celeano: return "Celeano"
        case .electra: return "Electra"
        case .taygeta: return "Taygeta"
        case .maia: return "Maia"
        case .asterope: return "Asterope"
        case .steropeIi: return "Sterope II"
        case .merope: return "Merope"
        case .atlas: return "Atlas"
        case .pleione: return "Pleione"
        case .atria: return "Atria"
        case .rasMutallah: return "Ras Mutallah"
        case .dubhe: return "Dubhe"
        case .merak: return "Merak"
        case .phecda: return "Phecda"
        case .megrez: return "Megrez"
        case .alioth: return "Alioth"
        case .mizar: return "Mizar"
        case .alkaid: return "Alkaid"
        case .alHaud: return "Al Haud"
        case .talithaBorealis: return "Talitha Borealis"
        case .talithaAustralis: return "Talitha Australis"
        case .taniaBorealis: return "Tania Borealis"
        case .taniaAustralis: return "Tania Australis"
        case .alulaBorealis: return "Alula Borealis"
        case .alulaAustralis: return "Alula Australis"
        case .muscida: return "Muscida"
        case .elKophrah: return "El Kophrah"
        case .alcor: return "Alcor"
        case .kochab: return "Kochab"
        case .pherkad: return "Pherkad"
        case .yildun: return "Yildun"
        case .urodelus: return "Urodelus"
        case .alifaAlFarkadain: return "Alifa Al Farkadain"
        case .anwarAlFarkadain: return "Anwar al Farkadain"
        case .pherkadMinor: return "Pherkad Minor"
        case .suhailAlMuhlif: return "Suhail al Muhlif"
        case .kooShe: return "Koo She"
        case .markeb: return "Markeb"
        case .alsuhail: return "Alsuhail"
        case .peregrini: return "Peregrini"
        case .xestus: return "Xestus"
        case .tseenKe: return "Tseen Ke"
        case .zavijava: return "Zavijava"
        case .porrima: return "Porrima"
        case .auva: return "Auva"
        case .vindemiatrix: return "Vindemiatrix"
        case .heze: return "Heze"
        case .zaniah: return "Zaniah"
        case .syrma: return "Syrma"
        case .khambalia: return "Khambalia"
        case .rijlAlAwwa: return "Rijl al Awwa"
        case .anser: return "Anser"
        }
    }

    var aliases: [String] {
        switch self {
        case .aldebaran: return []
        case .algol: return []
        case .antares: return []
        case .regulus: return []
        case .sirius: return []
        case .spica: return []
        case .galCenter: return []
        case .greatAttractor: return []
        case .virgoCluster: return []
        case .andromedaGalaxy: return []
        case .praesepeCluster: return []
        case .polaris: return []
        case .sanduleak: return []
        case .deneb: return ["Deneb Adige"]
        case .rigel: return []
        case .mira: return []
        case .ain: return []
        case .segin: return []
        case .alpheratz: return ["Sirrah"]
        case .mirach: return []
        case .almaak: return ["Almak", "Almac", "Almach"]
        case .adhil: return []
        case .adhab: return []
        case .altair: return []
        case .alshain: return []
        case .tarazed: return []
        case .alMizan: return []
        case .denebElOkabBorealis: return []
        case .denebElOkabAustralis: return ["Dheneb"]
        case .bazak: return []
        case .tseenFoo: return []
        case .alThalimaimPosterior: return []
        case .alThalimaimAnterior: return []
        case .bered: return []
        case .sadalmelek: return ["Sadalmelik"]
        case .sadalsuud: return []
        case .sadalachbia: return []
        case .skat: return []
        case .albali: return ["Altager"]
        case .sadaltager: return []
        case .hydria: return ["Deli"]
        case .ancha: return []
        case .situla: return []
        case .hydor: return ["Ekkhysis"]
        case .albulaan: return []
        case .seat: return []
        case .bunda: return []
        case .ara: return []
        case .hamal: return []
        case .sheratan: return []
        case .mesarthim: return []
        case .botein: return []
        case .capella: return []
        case .menkalinan: return []
        case .prijipati: return []
        case .maaz: return ["Al Anz"]
        case .haedi: return ["Haedus", "Hoedus I", "Sadatoni"]
        case .hoedusIi: return []
        case .bogardus: return ["Manus"]
        case .hasseleh: return ["Al Khabdhilinan"]
        case .arcturus: return []
        case .nekkar: return []
        case .seginus: return ["Haris"]
        case .princeps: return []
        case .izar: return ["Mirak", "Pulcherrima"]
        case .mufrid: return ["Muphrid"]
        case .asellusPrimus: return []
        case .asellusSecundus: return []
        case .asellusTertius: return []
        case .alkalurops: return []
        case .hemeleinPrima: return ["Al Hamalain"]
        case .hemeleinSecunda: return []
        case .ceginus: return []
        case .merga: return []
        case .algedi1: return ["Giedi Prima"]
        case .algedi2: return ["Giedi Secunda"]
        case .dabih: return []
        case .nashira: return []
        case .denebAlgedi: return []
        case .castra: return []
        case .marakk: return []
        case .armus: return []
        case .dorsum: return []
        case .alshat: return []
        case .oculus: return []
        case .bos: return []
        case .pazan: return ["Pazhan"]
        case .batenAlgiedi: return []
        case .canopus: return []
        case .miaplacidus: return []
        case .avior: return []
        case .foramen: return []
        case .vathorzPosterior: return []
        case .scutulum: return ["Tureis", "Aspidiske"]
        case .drus: return ["Drys"]
        case .simiram: return []
        case .vathorzPrior: return []
        case .schedar: return ["Shedir", "Schedir"]
        case .caph: return []
        case .tsih: return ["Cih"]
        case .ruchbah: return ["Rucha"]
        case .achird: return []
        case .marfak: return []
        case .rigilKent: return ["Rigel Kentaurus", "Toliman", "Bungula"]
        case .hadar: return ["Agena"]
        case .muhlifain: return []
        case .birdun: return []
        case .menkent: return []
        case .alhakim: return []
        case .keKwan: return []
        case .maTi: return ["Mati"]
        case .kabkentSecunda: return []
        case .kabkentTertia: return []
        case .proximaCentauri: return []
        case .alderamin: return []
        case .alphirk: return ["Alfirk"]
        case .alrai: return ["Errai"]
        case .alradif: return ["Alredif"]
        case .phicares: return ["Phicareus"]
        case .kurhah: return []
        case .alagemin: return []
        case .alkidr: return []
        case .alvahet: return []
        case .erakis: return ["The Garnet Star"]
        case .kurdah: return ["Alkurhah"]
        case .alKalbAlRai: return []
        case .menkar1: return []
        case .diphda: return ["Difda"]
        case .kaffaljidhma: return []
        case .phycochroma: return []
        case .batenKaitos: return []
        case .denebAlgenubi: return []
        case .altawk: return []
        case .denebKaitos: return ["Shemali"]
        case .menkar2: return []
        case .alSadrAlKetus: return []
        case .abyssusAqueus: return []
        case .alNitham: return []
        case .mirzam: return ["Murzim", "Murzims"]
        case .muliphein: return ["Isis"]
        case .wezen: return []
        case .adara: return ["Adhara"]
        case .furud: return []
        case .aludra: return []
        case .procyon: return []
        case .gomeisa: return []
        case .acubens: return []
        case .alTarf: return []
        case .asellusBorealis: return []
        case .asellusAustralis: return []
        case .tegmen: return ["Tegmine"]
        case .decapoda: return []
        case .phact: return []
        case .wazn: return []
        case .ghusnAlZaitun: return []
        case .alKurud: return []
        case .tsze: return []
        case .diadem: return []
        case .aldafirah: return []
        case .kissin: return []
        case .alphecca: return ["Alphekka", "Gemma"]
        case .nusakan: return []
        case .theBlazeStar: return []
        case .alfeccaMeridiana: return []
        case .alkes: return []
        case .alsharasif: return []
        case .labrum: return []
        case .acrux: return []
        case .mimosa: return []
        case .gacrux: return []
        case .decrux: return []
        case .juxtaCrucem: return []
        case .alchiba: return ["Alchita"]
        case .kraz: return []
        case .gienahCorvi: return []
        case .algorab: return []
        case .minkar: return []
        case .avisSatyra: return []
        case .corCaroli: return []
        case .asterion: return ["Chara"]
        case .albireo: return []
        case .sador: return ["Sadir", "Sadr"]
        case .ruc: return ["Rukh", "Urakhga", "Al Fawaris"]
        case .gienahCygni: return ["Gienah Ghurab"]
        case .azelfafage: return []
        case .ruchbahI: return []
        case .ruchbahIi: return []
        case .sualocin: return []
        case .rotanev: return []
        case .denebDulphim: return []
        case .thuban: return []
        case .alwaid: return ["Rastaban"]
        case .eltanin: return ["Etamin"]
        case .nodusIi: return ["Altais"]
        case .tyl: return []
        case .nodusI: return ["Aldhibah"]
        case .alsafi1: return []
        case .edasich: return ["Ed Asich"]
        case .ketu: return []
        case .giansar: return ["Gianfar"]
        case .arrakis: return []
        case .kuma1: return []
        case .kuma2: return []
        case .grumium: return []
        case .alsafi2: return ["Athafi"]
        case .batentabanBorealis: return []
        case .dziban: return []
        case .alathfar1: return ["Al Athfar"]
        case .aldhibain: return []
        case .batentabanAustralis: return []
        case .kitalpha: return []
        case .achernar: return []
        case .cursa: return []
        case .zaurak: return []
        case .rana: return []
        case .azha: return []
        case .acamar: return []
        case .zibal: return []
        case .beid: return []
        case .keid: return []
        case .angetenar: return []
        case .theemin: return []
        case .sceptrum: return []
        case .fornacis: return []
        case .castor: return []
        case .pollux: return []
        case .alhena: return ["Almeisan"]
        case .wasat: return []
        case .mebsuta: return []
        case .mekbuda: return []
        case .propusEtagem: return []
        case .nageba: return []
        case .propusIotgem: return []
        case .alKrikab: return []
        case .kebash: return ["Alkibash"]
        case .tejat: return []
        case .alzirr: return []
        case .alnair: return []
        case .gruid: return []
        case .alDhanab: return ["Ras Alkurki"]
        case .rasAlgethi: return ["Rasalgethi"]
        case .kornephoros: return []
        case .rutilicus: return []
        case .sarin: return []
        case .kajamEpsher: return []
        case .sofian: return []
        case .rukbalgethiGenubi: return []
        case .alJathiyah: return []
        case .marsik: return ["Marfik"]
        case .masym: return ["Maasym"]
        case .melkarth: return []
        case .fudail: return []
        case .rukbalgethiShemali: return []
        case .kajamOmeher: return ["Cujam"]
        case .apex: return []
        case .alphard: return ["Cor Hydrae"]
        case .caudaHydrae: return ["Dhanab al Shuja"]
        case .mautinah: return []
        case .ashlesha: return []
        case .hydrobius: return []
        case .pleura: return []
        case .sataghni: return []
        case .alMinliarAlShuja: return ["Minchir"]
        case .ukdah1: return []
        case .ukdah2: return []
        case .denebola: return []
        case .algieba1: return []
        case .dhur: return ["Zosma"]
        case .rasElasedAustralis: return []
        case .adhafera: return []
        case .algieba2: return ["Al Jabhah"]
        case .tseTseng: return ["Tsze Tseang"]
        case .alminhar: return ["Al Minliar al Asad"]
        case .alterf: return []
        case .rasElasedBorealis: return ["Rasalas"]
        case .subra: return []
        case .shishimai: return []
        case .coxa: return ["Chertan", "Cestan", "Chort"]
        case .shir: return []
        case .arneb: return []
        case .nihal: return []
        case .sasin: return []
        case .zubenelgenubi: return ["Zuben Elgenubi"]
        case .zubeneshamali: return ["Zuben Eschamali"]
        case .zubenelakrab: return ["Zuben Elakrab"]
        case .zubenelakribi: return ["Zuben Elakribi"]
        case .zubenhakrabi: return ["Zuben Hakrabi"]
        case .brachium: return []
        case .praecipua: return []
        case .kakkab: return ["Men"]
        case .kekouan: return []
        case .thusia: return []
        case .hilasmus: return []
        case .alvashak: return ["Al Fahd"]
        case .alsciaukat: return ["Mabsuthat"]
        case .mabsuthat: return []
        case .maculosa: return ["Maculata"]
        case .vega: return []
        case .sheliak: return []
        case .sulaphat: return ["Sulafat"]
        case .aladfar: return []
        case .alathfar2: return []
        case .polarisAustralis: return []
        case .rasalhague: return []
        case .celbalrai: return ["Kelb Alrai"]
        case .alDurajah: return []
        case .yedPrior: return []
        case .yedPosterior: return []
        case .han: return []
        case .sabik: return []
        case .imad: return []
        case .helkath: return []
        case .marfik: return []
        case .sinistra: return []
        case .barnardsStar: return []
        case .betelgeuse: return ["Beteigeuse"]
        case .bellatrix: return []
        case .mintaka: return []
        case .alnilam: return []
        case .alnitak: return []
        case .trapezium: return []
        case .hatsya: return ["Nair al Saif"]
        case .saiph: return []
        case .heka: return ["Meissa"]
        case .tabit1: return []
        case .tabit2: return []
        case .thabit: return []
        case .peacock: return []
        case .ankaa: return []
        case .markab: return []
        case .scheat: return []
        case .algenib: return []
        case .enif: return []
        case .homam: return []
        case .matar: return []
        case .biham: return ["Baham"]
        case .jih: return []
        case .sadalbari: return []
        case .kerb: return ["Salm"]
        case .mirfak: return ["Mirphak"]
        case .atik: return []
        case .miram: return []
        case .misam: return []
        case .menkib: return []
        case .atiks: return []
        case .gorgonaSecunda: return []
        case .gorgonaTertia: return []
        case .gorgonaQuatra: return []
        case .capulus1: return []
        case .capulus2: return []
        case .fomalhaut: return []
        case .tienKang: return []
        case .aboras: return []
        case .alrischa: return ["Al Rescha"]
        case .fumAlsamakah: return ["Samakah"]
        case .simmah: return []
        case .linteum: return []
        case .kaht: return []
        case .alPherg: return []
        case .torcularisSeptentrionalis: return []
        case .anunitum: return []
        case .vernalis: return []
        case .naos: return ["Suhail Hadar"]
        case .kaimana: return []
        case .azmidiske: return []
        case .ahadi: return []
        case .turais: return []
        case .alRihla: return ["Rehla", "Anazitisi"]
        case .graffias: return ["Akrab", "Acrab"]
        case .aculeus: return []
        case .acumen: return []
        case .dschubba: return []
        case .wei: return []
        case .sargas: return []
        case .girtab: return []
        case .shaula: return []
        case .jabbah: return []
        case .grafias: return []
        case .alniyat: return []
        case .lesath: return []
        case .jabhatAlAkrab1: return []
        case .jabhatAlAkrab2: return []
        case .unukalhai: return ["Cor Serpentis"]
        case .chow: return ["Zhou"]
        case .ainalhai: return []
        case .qin: return ["Chin"]
        case .nullaPambu: return []
        case .tang: return []
        case .alya: return []
        case .leiolepis: return ["Leiolepidotus"]
        case .nehushtan: return []
        case .sham: return []
        case .rukbat: return []
        case .arkabPrior: return []
        case .arkabPosterior: return []
        case .alnasl: return ["Nash"]
        case .kausMedis: return ["Kaus Meridionalis"]
        case .kausAustralis: return []
        case .ascella: return []
        case .sephdar: return ["Ira Furoris"]
        case .kausBorealis: return []
        case .polis: return []
        case .ainAlRami: return []
        case .manubrium: return []
        case .albaldah: return []
        case .nunki: return []
        case .hecatebolus: return []
        case .nanto: return []
        case .terebellium: return []
        case .facies: return []
        case .spiculum: return []
        case .elnath: return ["El Nath", "Alnath"]
        case .primaHyadum: return ["Hyadum I"]
        case .secundaHyadum: return ["Hyadum II"]
        case .alHecka: return []
        case .alcyone: return []
        case .phaeo: return []
        case .phaesula: return []
        case .althaur: return []
        case .kattupothu: return []
        case .furibundus: return []
        case .ushakaron: return []
        case .atirsagne: return []
        case .celeano: return []
        case .electra: return []
        case .taygeta: return []
        case .maia: return []
        case .asterope: return ["Sterope I"]
        case .steropeIi: return []
        case .merope: return []
        case .atlas: return []
        case .pleione: return []
        case .atria: return []
        case .rasMutallah: return ["Metallah"]
        case .dubhe: return []
        case .merak: return []
        case .phecda: return []
        case .megrez: return []
        case .alioth: return []
        case .mizar: return []
        case .alkaid: return ["Benetnash"]
        case .alHaud: return []
        case .talithaBorealis: return []
        case .talithaAustralis: return []
        case .taniaBorealis: return []
        case .taniaAustralis: return []
        case .alulaBorealis: return []
        case .alulaAustralis: return []
        case .muscida: return []
        case .elKophrah: return []
        case .alcor: return ["Saidak"]
        case .kochab: return []
        case .pherkad: return []
        case .yildun: return []
        case .urodelus: return []
        case .alifaAlFarkadain: return ["Farkadain", "Pharkadain"]
        case .anwarAlFarkadain: return []
        case .pherkadMinor: return []
        case .suhailAlMuhlif: return ["Regor"]
        case .kooShe: return []
        case .markeb: return []
        case .alsuhail: return ["Suhail"]
        case .peregrini: return ["Alherem"]
        case .xestus: return []
        case .tseenKe: return []
        case .zavijava: return ["Alaraph"]
        case .porrima: return []
        case .auva: return []
        case .vindemiatrix: return []
        case .heze: return []
        case .zaniah: return []
        case .syrma: return []
        case .khambalia: return []
        case .rijlAlAwwa: return ["Ril Alauva"]
        case .anser: return []
        }
    }

    var astronomicalName: String {
        switch self {
        case .aldebaran: return "alTau"
        case .algol: return "bePer"
        case .antares: return "alSco"
        case .regulus: return "alLeo"
        case .sirius: return "alCMa"
        case .spica: return "alVir"
        case .galCenter: return "SgrA*"
        case .greatAttractor: return "GA"
        case .virgoCluster: return "VC"
        case .andromedaGalaxy: return "M31"
        case .praesepeCluster: return "M44"
        case .polaris: return "alUMi"
        case .sanduleak: return "SN1987A"
        case .deneb: return "alCyg"
        case .rigel: return "beOri"
        case .mira: return "omiCet"
        case .ain: return "epTau"
        case .segin: return "epCas"
        case .alpheratz: return "alAnd"
        case .mirach: return "beAnd"
        case .almaak: return "ga-1And"
        case .adhil: return "xiAnd"
        case .adhab: return "upAnd"
        case .altair: return "alAql"
        case .alshain: return "beAql"
        case .tarazed: return "gaAql"
        case .alMizan: return "deAql"
        case .denebElOkabBorealis: return "epAql"
        case .denebElOkabAustralis: return "zeAql"
        case .bazak: return "etAql"
        case .tseenFoo: return "thAql"
        case .alThalimaimPosterior: return "ioAql"
        case .alThalimaimAnterior: return "laAql"
        case .bered: return "12Aql"
        case .sadalmelek: return "alAqr"
        case .sadalsuud: return "beAqr"
        case .sadalachbia: return "gaAqr"
        case .skat: return "deAqr"
        case .albali: return "epAqr"
        case .sadaltager: return "ze-1Aqr"
        case .hydria: return "etAqr"
        case .ancha: return "thAqr"
        case .situla: return "kaAqr"
        case .hydor: return "laAqr"
        case .albulaan: return "nuAqr"
        case .seat: return "piAqr"
        case .bunda: return "xiAqr"
        case .ara: return "alAra"
        case .hamal: return "alAri"
        case .sheratan: return "beAri"
        case .mesarthim: return "gaAri"
        case .botein: return "deAri"
        case .capella: return "alAur"
        case .menkalinan: return "beAur"
        case .prijipati: return "deAur"
        case .maaz: return "epAur"
        case .haedi: return "zeAur"
        case .hoedusIi: return "etAur"
        case .bogardus: return "thAur"
        case .hasseleh: return "ioAur"
        case .arcturus: return "alBoo"
        case .nekkar: return "beBoo"
        case .seginus: return "gaBoo"
        case .princeps: return "deBoo"
        case .izar: return "epBoo"
        case .mufrid: return "etBoo"
        case .asellusPrimus: return "thBoo"
        case .asellusSecundus: return "ioBoo"
        case .asellusTertius: return "ka-2Boo"
        case .alkalurops: return "mu-1Boo"
        case .hemeleinPrima: return "rhBoo"
        case .hemeleinSecunda: return "siBoo"
        case .ceginus: return "phBoo"
        case .merga: return "38Boo"
        case .algedi1: return "al-1Cap"
        case .algedi2: return "al-2Cap"
        case .dabih: return "beCap"
        case .nashira: return "gaCap"
        case .denebAlgedi: return "deCap"
        case .castra: return "epCap"
        case .marakk: return "zeCap"
        case .armus: return "etCap"
        case .dorsum: return "thCap"
        case .alshat: return "nuCap"
        case .oculus: return "piCap"
        case .bos: return "rhCap"
        case .pazan: return "psCap"
        case .batenAlgiedi: return "omeCap"
        case .canopus: return "alCar"
        case .miaplacidus: return "beCar"
        case .avior: return "epCar"
        case .foramen: return "etCar"
        case .vathorzPosterior: return "thCar"
        case .scutulum: return "ioCar"
        case .drus: return "chCar"
        case .simiram: return "omeCar"
        case .vathorzPrior: return "upCar"
        case .schedar: return "alCas"
        case .caph: return "beCas"
        case .tsih: return "gaCas"
        case .ruchbah: return "deCas"
        case .achird: return "etCas"
        case .marfak: return "muCas"
        case .rigilKent: return "alCen"
        case .hadar: return "beCen"
        case .muhlifain: return "gaCen"
        case .birdun: return "epCen"
        case .menkent: return "thCen"
        case .alhakim: return "ioCen"
        case .keKwan: return "kaCen"
        case .maTi: return "laCen"
        case .kabkentSecunda: return "nuCen"
        case .kabkentTertia: return "phCen"
        case .proximaCentauri: return "V645 Cen"
        case .alderamin: return "alCep"
        case .alphirk: return "beCep"
        case .alrai: return "gaCep"
        case .alradif: return "deCep"
        case .phicares: return "epCep"
        case .kurhah: return "zeCep"
        case .alagemin: return "etCep"
        case .alkidr: return "thCep"
        case .alvahet: return "ioCep"
        case .erakis: return "muCep"
        case .kurdah: return "xiCep"
        case .alKalbAlRai: return "rhCep"
        case .menkar1: return "alCet"
        case .diphda: return "beCet"
        case .kaffaljidhma: return "gaCet"
        case .phycochroma: return "deCet"
        case .batenKaitos: return "zeCet"
        case .denebAlgenubi: return "etCet"
        case .altawk: return "thCet"
        case .denebKaitos: return "ioCet"
        case .menkar2: return "laCet"
        case .alSadrAlKetus: return "piCet"
        case .abyssusAqueus: return "upCet"
        case .alNitham: return "ph-1Cet"
        case .mirzam: return "beCMa"
        case .muliphein: return "gaCMa"
        case .wezen: return "deCMa"
        case .adara: return "epCMa"
        case .furud: return "zeCMa"
        case .aludra: return "etCMa"
        case .procyon: return "alCMi"
        case .gomeisa: return "beCMi"
        case .acubens: return "alCnc"
        case .alTarf: return "beCnc"
        case .asellusBorealis: return "gaCnc"
        case .asellusAustralis: return "deCnc"
        case .tegmen: return "zeCnc"
        case .decapoda: return "ioCnc"
        case .phact: return "alCol"
        case .wazn: return "beCol"
        case .ghusnAlZaitun: return "deCol"
        case .alKurud: return "kaCol"
        case .tsze: return "laCol"
        case .diadem: return "alCom"
        case .aldafirah: return "beCom"
        case .kissin: return "gaCom"
        case .alphecca: return "alCrB"
        case .nusakan: return "beCrB"
        case .theBlazeStar: return "taCrB"
        case .alfeccaMeridiana: return "alCrA"
        case .alkes: return "alCrt"
        case .alsharasif: return "beCrt"
        case .labrum: return "deCrt"
        case .acrux: return "alCru"
        case .mimosa: return "beCru"
        case .gacrux: return "gaCru"
        case .decrux: return "deCru"
        case .juxtaCrucem: return "epCru"
        case .alchiba: return "alCrv"
        case .kraz: return "beCrv"
        case .gienahCorvi: return "gaCrv"
        case .algorab: return "deCrv"
        case .minkar: return "epCrv"
        case .avisSatyra: return "etCrv"
        case .corCaroli: return "al-2CVn"
        case .asterion: return "beCVn"
        case .albireo: return "be-1Cyg"
        case .sador: return "gaCyg"
        case .ruc: return "deCyg"
        case .gienahCygni: return "epCyg"
        case .azelfafage: return "pi-1Cyg"
        case .ruchbahI: return "ome-1Cyg"
        case .ruchbahIi: return "ome-2Cyg"
        case .sualocin: return "alDel"
        case .rotanev: return "beDel"
        case .denebDulphim: return "epDel"
        case .thuban: return "alDra"
        case .alwaid: return "beDra"
        case .eltanin: return "gaDra"
        case .nodusIi: return "deDra"
        case .tyl: return "epDra"
        case .nodusI: return "zeDra"
        case .alsafi1: return "thDra"
        case .edasich: return "ioDra"
        case .ketu: return "kaDra"
        case .giansar: return "laDra"
        case .arrakis: return "muDra"
        case .kuma1: return "nu-1Dra"
        case .kuma2: return "nu-2Dra"
        case .grumium: return "xiDra"
        case .alsafi2: return "siDra"
        case .batentabanBorealis: return "chDra"
        case .dziban: return "ps-1Dra"
        case .alathfar1: return "omeDra"
        case .aldhibain: return "etDra"
        case .batentabanAustralis: return "phDra"
        case .kitalpha: return "alEqu"
        case .achernar: return "alEri"
        case .cursa: return "beEri"
        case .zaurak: return "gaEri"
        case .rana: return "deEri"
        case .azha: return "etEri"
        case .acamar: return "th-1Eri"
        case .zibal: return "zeEri"
        case .beid: return "omi-1Eri"
        case .keid: return "omi-2Eri"
        case .angetenar: return "ta-2Eri"
        case .theemin: return "up-2Eri"
        case .sceptrum: return "53Eri"
        case .fornacis: return "alFor"
        case .castor: return "alGem"
        case .pollux: return "beGem"
        case .alhena: return "gaGem"
        case .wasat: return "deGem"
        case .mebsuta: return "epGem"
        case .mekbuda: return "zeGem"
        case .propusEtagem: return "etGem"
        case .nageba: return "thGem"
        case .propusIotgem: return "ioGem"
        case .alKrikab: return "kaGem"
        case .kebash: return "laGem"
        case .tejat: return "muGem"
        case .alzirr: return "xiGem"
        case .alnair: return "alGru"
        case .gruid: return "beGru"
        case .alDhanab: return "gaGru"
        case .rasAlgethi: return "alHer"
        case .kornephoros: return "beHer"
        case .rutilicus: return "zeHer"
        case .sarin: return "deHer"
        case .kajamEpsher: return "epHer"
        case .sofian: return "etHer"
        case .rukbalgethiGenubi: return "thHer"
        case .alJathiyah: return "ioHer"
        case .marsik: return "kaHer"
        case .masym: return "laHer"
        case .melkarth: return "muHer"
        case .fudail: return "piHer"
        case .rukbalgethiShemali: return "taHer"
        case .kajamOmeher: return "omeHer"
        case .apex: return "HerA*"
        case .alphard: return "alHya"
        case .caudaHydrae: return "gaHya"
        case .mautinah: return "deHya"
        case .ashlesha: return "epHya"
        case .hydrobius: return "zeHya"
        case .pleura: return "nuHya"
        case .sataghni: return "piHya"
        case .alMinliarAlShuja: return "siHya"
        case .ukdah1: return "ta-1Hya"
        case .ukdah2: return "ta-2Hya"
        case .denebola: return "beLeo"
        case .algieba1: return "ga-1Leo"
        case .dhur: return "deLeo"
        case .rasElasedAustralis: return "epLeo"
        case .adhafera: return "zeLeo"
        case .algieba2: return "etLeo"
        case .tseTseng: return "ioLeo"
        case .alminhar: return "kaLeo"
        case .alterf: return "laLeo"
        case .rasElasedBorealis: return "muLeo"
        case .subra: return "omiLeo"
        case .shishimai: return "siLeo"
        case .coxa: return "thLeo"
        case .shir: return "rhLeo"
        case .arneb: return "alLep"
        case .nihal: return "beLep"
        case .sasin: return "epLep"
        case .zubenelgenubi: return "al-2Lib"
        case .zubeneshamali: return "beLib"
        case .zubenelakrab: return "gaLib"
        case .zubenelakribi: return "deLib"
        case .zubenhakrabi: return "nuLib"
        case .brachium: return "siLib"
        case .praecipua: return "46 LMi"
        case .kakkab: return "alLup"
        case .kekouan: return "beLup"
        case .thusia: return "gaLup"
        case .hilasmus: return "deLup"
        case .alvashak: return "alLyn"
        case .alsciaukat: return "31Lyn"
        case .mabsuthat: return "kaLyn"
        case .maculosa: return "38Lyn"
        case .vega: return "alLyr"
        case .sheliak: return "beLyr"
        case .sulaphat: return "gaLyr"
        case .aladfar: return "etLyr"
        case .alathfar2: return "muLyr"
        case .polarisAustralis: return "siOct"
        case .rasalhague: return "alOph"
        case .celbalrai: return "beOph"
        case .alDurajah: return "gaOph"
        case .yedPrior: return "deOph"
        case .yedPosterior: return "epOph"
        case .han: return "zeOph"
        case .sabik: return "etOph"
        case .imad: return "thOph"
        case .helkath: return "kaOph"
        case .marfik: return "laOph"
        case .sinistra: return "nuOph"
        case .barnardsStar: return "V2500 Oph"
        case .betelgeuse: return "alOri"
        case .bellatrix: return "gaOri"
        case .mintaka: return "deOri"
        case .alnilam: return "epOri"
        case .alnitak: return "zeOri"
        case .trapezium: return "th-1COri"
        case .hatsya: return "ioOri"
        case .saiph: return "kaOri"
        case .heka: return "laOri"
        case .tabit1: return "pi-3Ori"
        case .tabit2: return "pi-4Ori"
        case .thabit: return "upOri"
        case .peacock: return "alPav"
        case .ankaa: return "alPhe"
        case .markab: return "alPeg"
        case .scheat: return "bePeg"
        case .algenib: return "gaPeg"
        case .enif: return "epPeg"
        case .homam: return "zePeg"
        case .matar: return "etPeg"
        case .biham: return "thPeg"
        case .jih: return "kaPeg"
        case .sadalbari: return "laPeg"
        case .kerb: return "taPeg"
        case .mirfak: return "alPer"
        case .atik: return "zePer"
        case .miram: return "etPer"
        case .misam: return "kaPer"
        case .menkib: return "xiPer"
        case .atiks: return "omiPer"
        case .gorgonaSecunda: return "piPer"
        case .gorgonaTertia: return "rhPer"
        case .gorgonaQuatra: return "omePer"
        case .capulus1: return "NGC869"
        case .capulus2: return "M34"
        case .fomalhaut: return "alPsA"
        case .tienKang: return "bePsA"
        case .aboras: return "dePsA"
        case .alrischa: return "alPsc"
        case .fumAlsamakah: return "bePsc"
        case .simmah: return "gaPsc"
        case .linteum: return "dePsc"
        case .kaht: return "epPsc"
        case .alPherg: return "etPsc"
        case .torcularisSeptentrionalis: return "omiPsc"
        case .anunitum: return "taPsc"
        case .vernalis: return "omePsc"
        case .naos: return "zePup"
        case .kaimana: return "nuPup"
        case .azmidiske: return "xiPup"
        case .ahadi: return "piPup"
        case .turais: return "rhPup"
        case .alRihla: return "taPup"
        case .graffias: return "be-1Sco"
        case .aculeus: return "M6"
        case .acumen: return "M7"
        case .dschubba: return "deSco"
        case .wei: return "epSco"
        case .sargas: return "thSco"
        case .girtab: return "kaSco"
        case .shaula: return "laSco"
        case .jabbah: return "nuSco"
        case .grafias: return "xiSco"
        case .alniyat: return "siSco"
        case .lesath: return "upSco"
        case .jabhatAlAkrab1: return "ome-1Sco"
        case .jabhatAlAkrab2: return "ome-2Sco"
        case .unukalhai: return "alSer"
        case .chow: return "beSer"
        case .ainalhai: return "gaSer"
        case .qin: return "deSer"
        case .nullaPambu: return "epSer"
        case .tang: return "etSer"
        case .alya: return "th-1Ser"
        case .leiolepis: return "muSer"
        case .nehushtan: return "xiSer"
        case .sham: return "alSge"
        case .rukbat: return "alSgr"
        case .arkabPrior: return "be-1Sgr"
        case .arkabPosterior: return "be-2Sgr"
        case .alnasl: return "ga-2Sgr"
        case .kausMedis: return "deSgr"
        case .kausAustralis: return "epSgr"
        case .ascella: return "zeSgr"
        case .sephdar: return "etSgr"
        case .kausBorealis: return "laSgr"
        case .polis: return "muSgr"
        case .ainAlRami: return "nu-1Sgr"
        case .manubrium: return "omiSgr"
        case .albaldah: return "piSgr"
        case .nunki: return "siSgr"
        case .hecatebolus: return "taSgr"
        case .nanto: return "phSgr"
        case .terebellium: return "omeSgr"
        case .facies: return "M22"
        case .spiculum: return "M8"
        case .elnath: return "beTau"
        case .primaHyadum: return "gaTau"
        case .secundaHyadum: return "de-1Tau"
        case .alHecka: return "zeTau"
        case .alcyone: return "etTau"
        case .phaeo: return "th-1Tau"
        case .phaesula: return "th-2Tau"
        case .althaur: return "laTau"
        case .kattupothu: return "muTau"
        case .furibundus: return "nuTau"
        case .ushakaron: return "xiTau"
        case .atirsagne: return "omiTau"
        case .celeano: return "16Tau"
        case .electra: return "17Tau"
        case .taygeta: return "19Tau"
        case .maia: return "20Tau"
        case .asterope: return "21Tau"
        case .steropeIi: return "22Tau"
        case .merope: return "23Tau"
        case .atlas: return "27Tau"
        case .pleione: return "28Tau"
        case .atria: return "alTrA"
        case .rasMutallah: return "alTri"
        case .dubhe: return "alUMa"
        case .merak: return "beUMa"
        case .phecda: return "gaUMa"
        case .megrez: return "deUMa"
        case .alioth: return "epUMa"
        case .mizar: return "zeUMa"
        case .alkaid: return "etUMa"
        case .alHaud: return "thUMa"
        case .talithaBorealis: return "ioUMa"
        case .talithaAustralis: return "kaUMa"
        case .taniaBorealis: return "laUMa"
        case .taniaAustralis: return "muUMa"
        case .alulaBorealis: return "nuUMa"
        case .alulaAustralis: return "xiUMa"
        case .muscida: return "omiUMa"
        case .elKophrah: return "chUMa"
        case .alcor: return "80Uma"
        case .kochab: return "beUMi"
        case .pherkad: return "gaUMi"
        case .yildun: return "deUMi"
        case .urodelus: return "epUMi"
        case .alifaAlFarkadain: return "zeUMi"
        case .anwarAlFarkadain: return "etUMi"
        case .pherkadMinor: return "11UMi"
        case .suhailAlMuhlif: return "ga-2Vel"
        case .kooShe: return "deVel"
        case .markeb: return "kaVel"
        case .alsuhail: return "laVel"
        case .peregrini: return "muVel"
        case .xestus: return "omiVel"
        case .tseenKe: return "phVel"
        case .zavijava: return "beVir"
        case .porrima: return "gaVir"
        case .auva: return "deVir"
        case .vindemiatrix: return "epVir"
        case .heze: return "zeVir"
        case .zaniah: return "etVir"
        case .syrma: return "ioVir"
        case .khambalia: return "laVir"
        case .rijlAlAwwa: return "muVir"
        case .anser: return "alVul"
        }
    }

    var magnitude: Double {
        switch self {
        case .aldebaran: return 0.985
        case .algol: return 2.12
        case .antares: return 1.09
        case .regulus: return 1.35
        case .sirius: return -1.47
        case .spica: return 1.04
        case .galCenter: return 999.99
        case .greatAttractor: return 999.99
        case .virgoCluster: return 999.99
        case .andromedaGalaxy: return 3.44
        case .praesepeCluster: return 3.7
        case .polaris: return 2.005
        case .sanduleak: return 4.81
        case .deneb: return 1.25
        case .rigel: return 0.12
        case .mira: return 3.04
        case .ain: return 3.54
        case .segin: return 3.342
        case .alpheratz: return 2.06
        case .mirach: return 2.06
        case .almaak: return 2.26
        case .adhil: return 4.875
        case .adhab: return 4.09
        case .altair: return 0.77
        case .alshain: return 3.71
        case .tarazed: return 2.724
        case .alMizan: return 3.4
        case .denebElOkabBorealis: return 4.025
        case .denebElOkabAustralis: return 2.988
        case .bazak: return 3.88
        case .tseenFoo: return 3.242
        case .alThalimaimPosterior: return 4.349
        case .alThalimaimAnterior: return 3.427
        case .bered: return 4.027
        case .sadalmelek: return 2.95
        case .sadalsuud: return 2.91
        case .sadalachbia: return 3.847
        case .skat: return 3.269
        case .albali: return 3.77
        case .sadaltager: return 4.5
        case .hydria: return 4.03
        case .ancha: return 4.175
        case .situla: return 5.04
        case .hydor: return 3.766
        case .albulaan: return 4.519
        case .seat: return 4.794
        case .bunda: return 4.69
        case .ara: return 2.836
        case .hamal: return 2.0
        case .sheratan: return 2.64
        case .mesarthim: return 3.88
        case .botein: return 4.35
        case .capella: return 0.08
        case .menkalinan: return 1.896
        case .prijipati: return 3.72
        case .maaz: return 3.039
        case .haedi: return 3.769
        case .hoedusIi: return 3.158
        case .bogardus: return 2.62
        case .hasseleh: return 2.693
        case .arcturus: return -0.04
        case .nekkar: return 3.488
        case .seginus: return 3.0
        case .princeps: return 3.47
        case .izar: return 2.39
        case .mufrid: return 2.68
        case .asellusPrimus: return 4.1
        case .asellusSecundus: return 4.75
        case .asellusTertius: return 4.5
        case .alkalurops: return 4.307
        case .hemeleinPrima: return 3.583
        case .hemeleinSecunda: return 4.46
        case .ceginus: return 5.263
        case .merga: return 5.769
        case .algedi1: return 4.249
        case .algedi2: return 3.585
        case .dabih: return 3.08
        case .nashira: return 3.68
        case .denebAlgedi: return 2.87
        case .castra: return 4.5
        case .marakk: return 3.754
        case .armus: return 4.856
        case .dorsum: return 4.073
        case .alshat: return 4.754
        case .oculus: return 5.25
        case .bos: return 4.803
        case .pazan: return 4.152
        case .batenAlgiedi: return 4.124
        case .canopus: return -0.72
        case .miaplacidus: return 1.7
        case .avior: return 1.953
        case .foramen: return 8.13
        case .vathorzPosterior: return 2.78
        case .scutulum: return 2.249
        case .drus: return 3.444
        case .simiram: return 3.3
        case .vathorzPrior: return 2.96
        case .schedar: return 2.252
        case .caph: return 2.27
        case .tsih: return 2.47
        case .ruchbah: return 2.68
        case .achird: return 3.45
        case .marfak: return 5.12
        case .rigilKent: return -0.1
        case .hadar: return 0.6
        case .muhlifain: return 2.18
        case .birdun: return 2.265
        case .menkent: return 2.06
        case .alhakim: return 2.7
        case .keKwan: return 3.13
        case .maTi: return 3.117
        case .kabkentSecunda: return 3.39
        case .kabkentTertia: return 3.806
        case .proximaCentauri: return 11.05
        case .alderamin: return 2.46
        case .alphirk: return 3.216
        case .alrai: return 3.22
        case .alradif: return 4.07
        case .phicares: return 4.19
        case .kurhah: return 3.359
        case .alagemin: return 3.41
        case .alkidr: return 4.22
        case .alvahet: return 3.51
        case .erakis: return 4.04
        case .kurdah: return 6.5
        case .alKalbAlRai: return 5.46
        case .menkar1: return 2.514
        case .diphda: return 2.04
        case .kaffaljidhma: return 3.47
        case .phycochroma: return 4.07
        case .batenKaitos: return 3.738
        case .denebAlgenubi: return 3.45
        case .altawk: return 3.6
        case .denebKaitos: return 3.558
        case .menkar2: return 4.701
        case .alSadrAlKetus: return 4.235
        case .abyssusAqueus: return 4.015
        case .alNitham: return 4.775
        case .mirzam: return 2.0
        case .muliphein: return 4.097
        case .wezen: return 1.842
        case .adara: return 1.513
        case .furud: return 3.0
        case .aludra: return 2.4
        case .procyon: return 0.34
        case .gomeisa: return 2.886
        case .acubens: return 4.259
        case .alTarf: return 3.52
        case .asellusBorealis: return 4.668
        case .asellusAustralis: return 3.94
        case .tegmen: return 5.05
        case .decapoda: return 4.028
        case .phact: return 2.6
        case .wazn: return 3.12
        case .ghusnAlZaitun: return 3.853
        case .alKurud: return 4.374
        case .tsze: return 4.863
        case .diadem: return 4.32
        case .aldafirah: return 4.26
        case .kissin: return 4.35
        case .alphecca: return 2.214
        case .nusakan: return 3.68
        case .theBlazeStar: return 4.76
        case .alfeccaMeridiana: return 4.102
        case .alkes: return 4.07
        case .alsharasif: return 4.461
        case .labrum: return 3.56
        case .acrux: return 0.81
        case .mimosa: return 1.297
        case .gacrux: return 1.63
        case .decrux: return 2.775
        case .juxtaCrucem: return 3.59
        case .alchiba: return 4.0
        case .kraz: return 2.65
        case .gienahCorvi: return 2.59
        case .algorab: return 2.95
        case .minkar: return 3.017
        case .avisSatyra: return 4.31
        case .corCaroli: return 2.9
        case .asterion: return 4.26
        case .albireo: return 3.085
        case .sador: return 2.237
        case .ruc: return 2.9
        case .gienahCygni: return 2.48
        case .azelfafage: return 4.66
        case .ruchbahI: return 4.938
        case .ruchbahIi: return 5.468
        case .sualocin: return 3.8
        case .rotanev: return 3.632
        case .denebDulphim: return 4.032
        case .thuban: return 3.68
        case .alwaid: return 2.79
        case .eltanin: return 2.23
        case .nodusIi: return 3.082
        case .tyl: return 3.83
        case .nodusI: return 3.174
        case .alsafi1: return 4.0
        case .edasich: return 3.31
        case .ketu: return 3.881
        case .giansar: return 3.828
        case .arrakis: return 4.92
        case .kuma1: return 4.888
        case .kuma2: return 4.865
        case .grumium: return 3.741
        case .alsafi2: return 4.68
        case .batentabanBorealis: return 3.58
        case .dziban: return 4.56
        case .alathfar1: return 4.8
        case .aldhibain: return 2.736
        case .batentabanAustralis: return 4.22
        case .kitalpha: return 3.949
        case .achernar: return 0.5
        case .cursa: return 2.79
        case .zaurak: return 2.978
        case .rana: return 3.51
        case .azha: return 3.89
        case .acamar: return 3.2
        case .zibal: return 4.792
        case .beid: return 4.04
        case .keid: return 4.41
        case .angetenar: return 4.75
        case .theemin: return 3.817
        case .sceptrum: return 3.85
        case .fornacis: return 3.85
        case .castor: return 1.59
        case .pollux: return 1.15
        case .alhena: return 1.9
        case .wasat: return 3.53
        case .mebsuta: return 3.019
        case .mekbuda: return 4.01
        case .propusEtagem: return 3.32
        case .nageba: return 3.6
        case .propusIotgem: return 3.793
        case .alKrikab: return 3.57
        case .kebash: return 3.581
        case .tejat: return 2.914
        case .alzirr: return 3.4
        case .alnair: return 1.74
        case .gruid: return 2.13
        case .alDhanab: return 3.01
        case .rasAlgethi: return 3.06
        case .kornephoros: return 2.786
        case .rutilicus: return 2.8
        case .sarin: return 3.126
        case .kajamEpsher: return 3.906
        case .sofian: return 3.487
        case .rukbalgethiGenubi: return 3.851
        case .alJathiyah: return 3.8
        case .marsik: return 5.0
        case .masym: return 4.402
        case .melkarth: return 3.417
        case .fudail: return 3.156
        case .rukbalgethiShemali: return 3.9
        case .kajamOmeher: return 4.574
        case .apex: return 999.99
        case .alphard: return 2.004
        case .caudaHydrae: return 3.0
        case .mautinah: return 4.137
        case .ashlesha: return 3.38
        case .hydrobius: return 3.127
        case .pleura: return 3.11
        case .sataghni: return 3.263
        case .alMinliarAlShuja: return 4.452
        case .ukdah1: return 4.6
        case .ukdah2: return 4.555
        case .denebola: return 2.14
        case .algieba1: return 2.12
        case .dhur: return 2.56
        case .rasElasedAustralis: return 2.975
        case .adhafera: return 3.443
        case .algieba2: return 3.511
        case .tseTseng: return 4.0
        case .alminhar: return 4.473
        case .alterf: return 4.317
        case .rasElasedBorealis: return 3.88
        case .subra: return 3.531
        case .shishimai: return 4.044
        case .coxa: return 3.324
        case .shir: return 3.87
        case .arneb: return 2.597
        case .nihal: return 2.84
        case .sasin: return 3.192
        case .zubenelgenubi: return 2.753
        case .zubeneshamali: return 2.605
        case .zubenelakrab: return 3.925
        case .zubenelakribi: return 4.95
        case .zubenhakrabi: return 5.202
        case .brachium: return 3.3
        case .praecipua: return 3.83
        case .kakkab: return 2.276
        case .kekouan: return 2.665
        case .thusia: return 2.765
        case .hilasmus: return 3.203
        case .alvashak: return 3.16
        case .alsciaukat: return 4.258
        case .mabsuthat: return 4.258
        case .maculosa: return 3.82
        case .vega: return 0.03
        case .sheliak: return 3.52
        case .sulaphat: return 3.25
        case .aladfar: return 4.397
        case .alathfar2: return 5.12
        case .polarisAustralis: return 5.42
        case .rasalhague: return 2.1
        case .celbalrai: return 2.75
        case .alDurajah: return 3.75
        case .yedPrior: return 2.74
        case .yedPosterior: return 3.24
        case .han: return 2.578
        case .sabik: return 2.43
        case .imad: return 3.248
        case .helkath: return 3.2
        case .marfik: return 3.9
        case .sinistra: return 3.309
        case .barnardsStar: return 9.511
        case .betelgeuse: return 0.42
        case .bellatrix: return 1.64
        case .mintaka: return 2.23
        case .alnilam: return 1.7
        case .alnitak: return 1.79
        case .trapezium: return 5.13
        case .hatsya: return 2.77
        case .saiph: return 2.049
        case .heka: return 3.39
        case .tabit1: return 3.19
        case .tabit2: return 3.68
        case .thabit: return 4.62
        case .peacock: return 1.91
        case .ankaa: return 2.37
        case .markab: return 2.49
        case .scheat: return 2.42
        case .algenib: return 2.83
        case .enif: return 2.404
        case .homam: return 3.4
        case .matar: return 2.948
        case .biham: return 3.5
        case .jih: return 4.159
        case .sadalbari: return 3.961
        case .kerb: return 4.592
        case .mirfak: return 1.816
        case .atik: return 2.883
        case .miram: return 3.774
        case .misam: return 3.8
        case .menkib: return 4.06
        case .atiks: return 3.855
        case .gorgonaSecunda: return 4.685
        case .gorgonaTertia: return 3.42
        case .gorgonaQuatra: return 3.7
        case .capulus1: return 3.7
        case .capulus2: return 5.2
        case .fomalhaut: return 1.16
        case .tienKang: return 4.289
        case .aboras: return 4.226
        case .alrischa: return 3.82
        case .fumAlsamakah: return 4.486
        case .simmah: return 3.69
        case .linteum: return 4.439
        case .kaht: return 4.28
        case .alPherg: return 3.62
        case .torcularisSeptentrionalis: return 4.272
        case .anunitum: return 4.523
        case .vernalis: return 4.036
        case .naos: return 2.21
        case .kaimana: return 3.171
        case .azmidiske: return 3.337
        case .ahadi: return 2.729
        case .turais: return 2.81
        case .alRihla: return 2.93
        case .graffias: return 4.89
        case .aculeus: return 4.2
        case .acumen: return 3.3
        case .dschubba: return 2.291
        case .wei: return 2.29
        case .sargas: return 1.862
        case .girtab: return 2.375
        case .shaula: return 1.62
        case .jabbah: return 4.0
        case .grafias: return 4.17
        case .alniyat: return 2.912
        case .lesath: return 2.7
        case .jabhatAlAkrab1: return 3.946
        case .jabhatAlAkrab2: return 4.328
        case .unukalhai: return 2.63
        case .chow: return 3.66
        case .ainalhai: return 3.85
        case .qin: return 3.79
        case .nullaPambu: return 3.713
        case .tang: return 3.26
        case .alya: return 4.62
        case .leiolepis: return 3.548
        case .nehushtan: return 3.539
        case .sham: return 4.392
        case .rukbat: return 3.95
        case .arkabPrior: return 3.954
        case .arkabPosterior: return 4.281
        case .alnasl: return 2.99
        case .kausMedis: return 2.71
        case .kausAustralis: return 1.8
        case .ascella: return 2.607
        case .sephdar: return 3.11
        case .kausBorealis: return 2.833
        case .polis: return 3.841
        case .ainAlRami: return 4.859
        case .manubrium: return 3.771
        case .albaldah: return 2.89
        case .nunki: return 2.058
        case .hecatebolus: return 3.32
        case .nanto: return 3.161
        case .terebellium: return 4.7
        case .facies: return 6.17
        case .spiculum: return 4.6
        case .elnath: return 1.68
        case .primaHyadum: return 3.654
        case .secundaHyadum: return 3.764
        case .alHecka: return 3.03
        case .alcyone: return 2.873
        case .phaeo: return 3.84
        case .phaesula: return 3.41
        case .althaur: return 3.408
        case .kattupothu: return 4.28
        case .furibundus: return 3.898
        case .ushakaron: return 3.727
        case .atirsagne: return 3.6
        case .celeano: return 5.448
        case .electra: return 3.705
        case .taygeta: return 4.291
        case .maia: return 3.871
        case .asterope: return 5.761
        case .steropeIi: return 6.43
        case .merope: return 4.164
        case .atlas: return 3.62
        case .pleione: return 5.048
        case .atria: return 1.92
        case .rasMutallah: return 3.41
        case .dubhe: return 1.79
        case .merak: return 2.346
        case .phecda: return 2.44
        case .megrez: return 3.32
        case .alioth: return 1.76
        case .mizar: return 2.27
        case .alkaid: return 1.852
        case .alHaud: return 3.2
        case .talithaBorealis: return 3.1
        case .talithaAustralis: return 3.6
        case .taniaBorealis: return 3.442
        case .taniaAustralis: return 3.066
        case .alulaBorealis: return 3.504
        case .alulaAustralis: return 3.78
        case .muscida: return 3.362
        case .elKophrah: return 3.707
        case .alcor: return 4.01
        case .kochab: return 2.078
        case .pherkad: return 3.027
        case .yildun: return 4.348
        case .urodelus: return 4.222
        case .alifaAlFarkadain: return 4.283
        case .anwarAlFarkadain: return 4.95
        case .pherkadMinor: return 5.024
        case .suhailAlMuhlif: return 1.808
        case .kooShe: return 1.95
        case .markeb: return 2.464
        case .alsuhail: return 2.226
        case .peregrini: return 2.721
        case .xestus: return 3.63
        case .tseenKe: return 3.5
        case .zavijava: return 3.61
        case .porrima: return 2.74
        case .auva: return 3.38
        case .vindemiatrix: return 2.83
        case .heze: return 3.4
        case .zaniah: return 3.89
        case .syrma: return 4.1
        case .khambalia: return 4.52
        case .rijlAlAwwa: return 3.9
        case .anser: return 4.451
        }
    }

    var selectionMembership: StarSelectionMembership {
        switch self {
        case .aldebaran: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .algol: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .antares: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .regulus: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .sirius: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .spica: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .galCenter: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .greatAttractor: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .virgoCluster: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .andromedaGalaxy: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .praesepeCluster: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .polaris: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .sanduleak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .deneb: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .rigel: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .mira: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ain: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .segin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alpheratz: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .mirach: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .almaak: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .adhil: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .adhab: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .altair: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .alshain: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tarazed: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alMizan: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .denebElOkabBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .denebElOkabAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .bazak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tseenFoo: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alThalimaimPosterior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alThalimaimAnterior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .bered: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sadalmelek: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .sadalsuud: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .sadalachbia: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .skat: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .albali: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sadaltager: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hydria: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ancha: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .situla: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hydor: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .albulaan: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .seat: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .bunda: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ara: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hamal: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .sheratan: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .mesarthim: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .botein: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .capella: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .menkalinan: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: false)
        case .prijipati: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .maaz: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .haedi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hoedusIi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .bogardus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hasseleh: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .arcturus: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .nekkar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .seginus: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .princeps: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .izar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .mufrid: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .asellusPrimus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .asellusSecundus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .asellusTertius: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alkalurops: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hemeleinPrima: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hemeleinSecunda: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ceginus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .merga: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .algedi1: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .algedi2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .dabih: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .nashira: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .denebAlgedi: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .castra: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .marakk: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .armus: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .dorsum: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .alshat: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .oculus: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .bos: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .pazan: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .batenAlgiedi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .canopus: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .miaplacidus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .avior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .foramen: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .vathorzPosterior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .scutulum: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .drus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .simiram: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .vathorzPrior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .schedar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .caph: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tsih: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ruchbah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .achird: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .marfak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rigilKent: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .hadar: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .muhlifain: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .birdun: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .menkent: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alhakim: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .keKwan: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .maTi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kabkentSecunda: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kabkentTertia: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .proximaCentauri: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alderamin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .alphirk: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alrai: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alradif: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .phicares: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kurhah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alagemin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alkidr: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alvahet: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .erakis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kurdah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alKalbAlRai: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .menkar1: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .diphda: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .kaffaljidhma: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .phycochroma: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .batenKaitos: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .denebAlgenubi: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .altawk: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .denebKaitos: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .menkar2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alSadrAlKetus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .abyssusAqueus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alNitham: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .mirzam: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .muliphein: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .wezen: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .adara: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .furud: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .aludra: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .procyon: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .gomeisa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .acubens: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .alTarf: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .asellusBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .asellusAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .tegmen: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .decapoda: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .phact: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .wazn: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ghusnAlZaitun: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alKurud: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tsze: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .diadem: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .aldafirah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kissin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alphecca: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .nusakan: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .theBlazeStar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alfeccaMeridiana: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alkes: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .alsharasif: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .labrum: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .acrux: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .mimosa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .gacrux: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .decrux: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .juxtaCrucem: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alchiba: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kraz: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .gienahCorvi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .algorab: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .minkar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .avisSatyra: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .corCaroli: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .asterion: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .albireo: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .sador: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ruc: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .gienahCygni: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .azelfafage: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ruchbahI: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ruchbahIi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sualocin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .rotanev: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .denebDulphim: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .thuban: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .alwaid: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .eltanin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .nodusIi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tyl: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .nodusI: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alsafi1: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .edasich: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ketu: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .giansar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .arrakis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kuma1: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kuma2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .grumium: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alsafi2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .batentabanBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .dziban: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alathfar1: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .aldhibain: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .batentabanAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kitalpha: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .achernar: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .cursa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .zaurak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rana: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .azha: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .acamar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .zibal: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .beid: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .keid: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .angetenar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .theemin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sceptrum: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .fornacis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .castor: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .pollux: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .alhena: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .wasat: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .mebsuta: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .mekbuda: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .propusEtagem: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .nageba: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .propusIotgem: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .alKrikab: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kebash: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tejat: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .alzirr: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alnair: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .gruid: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alDhanab: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rasAlgethi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .kornephoros: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rutilicus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sarin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kajamEpsher: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sofian: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rukbalgethiGenubi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alJathiyah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .marsik: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .masym: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .melkarth: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .fudail: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rukbalgethiShemali: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kajamOmeher: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .apex: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alphard: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .caudaHydrae: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .mautinah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ashlesha: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hydrobius: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .pleura: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sataghni: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alMinliarAlShuja: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ukdah1: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ukdah2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .denebola: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .algieba1: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .dhur: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .rasElasedAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .adhafera: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .algieba2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tseTseng: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alminhar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alterf: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rasElasedBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .subra: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .shishimai: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .coxa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .shir: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .arneb: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .nihal: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sasin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .zubenelgenubi: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .zubeneshamali: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .zubenelakrab: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .zubenelakribi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .zubenhakrabi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .brachium: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .praecipua: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kakkab: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kekouan: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .thusia: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hilasmus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alvashak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alsciaukat: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .mabsuthat: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .maculosa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .vega: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .sheliak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sulaphat: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .aladfar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alathfar2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .polarisAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rasalhague: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .celbalrai: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alDurajah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .yedPrior: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .yedPosterior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .han: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .sabik: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .imad: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .helkath: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .marfik: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sinistra: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .barnardsStar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .betelgeuse: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .bellatrix: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .mintaka: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .alnilam: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .alnitak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .trapezium: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .hatsya: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .saiph: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .heka: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tabit1: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tabit2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .thabit: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .peacock: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ankaa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .markab: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .scheat: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .algenib: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .enif: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .homam: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .matar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .biham: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .jih: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sadalbari: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kerb: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .mirfak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .atik: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .miram: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .misam: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .menkib: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .atiks: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .gorgonaSecunda: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .gorgonaTertia: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .gorgonaQuatra: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .capulus1: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .capulus2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .fomalhaut: return StarSelectionMembership(inPtolemy: true, inRobson: true, inBrady: true)
        case .tienKang: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .aboras: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alrischa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .fumAlsamakah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .simmah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .linteum: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kaht: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alPherg: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .torcularisSeptentrionalis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .anunitum: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .vernalis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .naos: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kaimana: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .azmidiske: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ahadi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .turais: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alRihla: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .graffias: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .aculeus: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .acumen: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .dschubba: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .wei: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sargas: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .girtab: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .shaula: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .jabbah: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .grafias: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alniyat: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .lesath: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .jabhatAlAkrab1: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .jabhatAlAkrab2: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .unukalhai: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .chow: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ainalhai: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .qin: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .nullaPambu: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tang: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alya: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .leiolepis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .nehushtan: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .sham: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rukbat: return StarSelectionMembership(inPtolemy: true, inRobson: false, inBrady: true)
        case .arkabPrior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .arkabPosterior: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alnasl: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kausMedis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kausAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ascella: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .sephdar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kausBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .polis: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .ainAlRami: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .manubrium: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .albaldah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .nunki: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .hecatebolus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .nanto: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .terebellium: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .facies: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .spiculum: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .elnath: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .primaHyadum: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .secundaHyadum: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alHecka: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .alcyone: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .phaeo: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .phaesula: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .althaur: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kattupothu: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .furibundus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .ushakaron: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .atirsagne: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .celeano: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .electra: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .taygeta: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .maia: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .asterope: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .steropeIi: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .merope: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .atlas: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .pleione: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .atria: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .rasMutallah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .dubhe: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: true)
        case .merak: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .phecda: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .megrez: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alioth: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .mizar: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alkaid: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alHaud: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .talithaBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .talithaAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .taniaBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .taniaAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alulaBorealis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alulaAustralis: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .muscida: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .elKophrah: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alcor: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kochab: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .pherkad: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .yildun: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .urodelus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .alifaAlFarkadain: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .anwarAlFarkadain: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .pherkadMinor: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .suhailAlMuhlif: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .kooShe: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .markeb: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .alsuhail: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .peregrini: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .xestus: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .tseenKe: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .zavijava: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .porrima: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .auva: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .vindemiatrix: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: true)
        case .heze: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .zaniah: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .syrma: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .khambalia: return StarSelectionMembership(inPtolemy: false, inRobson: true, inBrady: false)
        case .rijlAlAwwa: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        case .anser: return StarSelectionMembership(inPtolemy: false, inRobson: false, inBrady: false)
        }
    }

}
