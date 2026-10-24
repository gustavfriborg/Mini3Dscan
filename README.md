# Mini3DScan

Lille test-app, der viser at vi kan bygge en usigneret iOS-app i skyen og lægge den på en iPhone med SideStore. Der skal ikke bruges en Mac til selve app-bygget, og der skal ikke bruges en betalt Apple Developer-konto.

Appen viser et live ARKit-billede med LiDAR-rekonstruktion (`sceneReconstruction = .mesh`) som trådnet. Knappen **Gem scanning** skriver alle `ARMeshAnchor`s til én OBJ-fil i meter og åbner iOS-delearket. Filen ligger også i Dokumenter, så den kan ses i appen Filer.

## Hent IPA

Seneste usignerede build, uden login:

https://github.com/gustavfriborg/Mini3Dscan/releases/download/latest/Mini3DScan.ipa

Hver grøn kørsel lægger også sin egen fil på et `build-<nummer>`-tag.

## Installer med SideStore

SideStore signerer IPA-filen med dit gratis Apple-id. Første gang SideStore skal på telefonen, skal du bruge en computer én gang (Windows, Linux eller Mac). Derefter kan apps fornyes over Wi-Fi. Følg den aktuelle guide: [docs.sidestore.io](https://docs.sidestore.io/docs/installation/prerequisites).

Når SideStore er sat op:

1. Slå **LocalDevVPN** til. Den skal være forbundet, mens du installerer eller fornyer.
2. Åbn download-linket ovenfor i Safari på iPhone, og gem `Mini3DScan.ipa` i appen Filer.
3. Åbn SideStore → **Mine apps** → **+**, og vælg `Mini3DScan.ipa`.
4. Første gang: **Indstillinger → Generelt → VPN og enhedsadministration**, og godkend dit Apple-id.
5. På nyere iOS: slå **Udviklertilstand** til under **Indstillinger → Anonymitet og sikkerhed**. Telefonen genstarter.
6. Åbn Mini3DScan, og tillad kameraet.

Et gratis Apple-id kan have tre aktive apps ad gangen (SideStore tæller med), og signaturen udløber efter 7 dage. Forny ved at trykke på dagtælleren i SideStore, mens LocalDevVPN er forbundet og telefonen er på Wi-Fi.

## Brug appen

1. Peg telefonen langsomt rundt i rummet, til det hvide trådnet tegnes.
2. Tryk **Gem scanning**.
3. Vælg Filer, Beskeder eller en anden app i delearket.
4. Den samme `.obj` ligger i **Filer → På min iPhone → Mini3DScan**.

Uden LiDAR viser appen en dansk besked og starter ikke et scan.

## Byg

Workflowet [Build unsigned IPA](.github/workflows/build-ipa.yml) kører på GitHubs gratis macOS-runner, når der pushes til `main` eller `cursor/**`, og når det startes manuelt. Det installerer XcodeGen 2.46.0, genererer projektet fra `project.yml`, bygger til `iphoneos` med `CODE_SIGNING_ALLOWED=NO` og pakker `Payload/Mini3DScan.app` som `Mini3DScan.ipa`. Filen uploades som workflow-artifact og som GitHub Release.

Bundle-id: `dk.friborg.mini3dscan`. Minimum iOS 17. Ingen tredjepartsbiblioteker.
