# Mini3Dscan

Usignerede iOS-apps, bygget på GitHub Actions' gratis macOS-runner, så de kan installeres med SideStore og et gratis Apple-id. Ingen Mac og ingen betalt Apple Developer-konto til selve bygget.

## 3D Model Anything (HouseCapture)

Den app, der skal på telefonen, er Wes Bos' open source-app til at scanne rum med LiDAR. Kilden hentes ved build fra [wesbos/3d-model-anything](https://github.com/wesbos/3d-model-anything) på commit `31b2dc9da3fb541e501f2f0936e55b32afb70ee8`, mappen `apps/house-capture`. Den bliver ikke kopieret ind i dette repo. Demo-filer under `data/` og `docs/images/thumb-1.png` hentes ikke med og ligger ikke i IPA'en. De har særskilte vilkår, se upstream [ASSETS-LICENSE.md](https://github.com/wesbos/3d-model-anything/blob/31b2dc9da3fb541e501f2f0936e55b32afb70ee8/ASSETS-LICENSE.md).

Kildekoden er MIT. Copyright (c) 2026 Wes Bos. Den fulde licenstekst står nederst.

### Hent IPA

Uden login:

https://github.com/gustavfriborg/Mini3Dscan/releases/download/house-capture-latest/HouseCapture.ipa

Hver grøn kørsel lægger også filen på `house-capture-build-<nummer>`.

- Visningsnavn: **3D Model Anything**
- Bundle-id: `com.wesbos.housecapture`
- Minimum iOS: **17.0**
- Scanning kræver iPhone eller iPad med LiDAR. Uden LiDAR kan appen importere, se og dele eksisterende scanninger.

### Det der ikke blev strippet

Appen har ingen entitlements-fil og ingen capabilities, som et gratis Apple-id ikke kan signere. Der er ingen App Groups, iCloud/CloudKit, push, associated domains, keychain-deling eller app-udvidelser. Workflowet bygger med `CODE_SIGNING_ALLOWED=NO` og fjerner en eventuel codesign-signatur, så SideStore kan signere IPA'en med dit Apple-id. Kamerabrug, RoomPlan og LiDAR-mesh kræver ikke en betalt konto.

Begrænsninger der stadig gælder ved sideload:

- Et gratis Apple-id kan have tre aktive apps, og SideStore tæller med. Signaturen udløber efter 7 dage og skal fornyes i SideStore på Wi-Fi med LocalDevVPN slået til.
- Første installation af SideStore kræver en computer én gang. Derefter kan apps fornyes uden computer. Se [docs.sidestore.io](https://docs.sidestore.io/docs/installation/prerequisites).
- På nyere iOS skal Udviklertilstand være slået til, og udvikleren (dit Apple-id) skal godkendes under Indstillinger → Generelt → VPN og enhedsadministration.
- Appen gemmer scanninger lokalt i Dokumenter (også synlige i Filer). Den synkroniserer ikke til iCloud.

### Installer med SideStore

1. Slå **LocalDevVPN** til.
2. Åbn linket ovenfor i Safari, og gem `HouseCapture.ipa` i Filer.
3. SideStore → **Mine apps** → **+** → vælg `HouseCapture.ipa`.
4. Godkend dit Apple-id, slå Udviklertilstand til hvis iOS beder om det, og åbn **3D Model Anything**.
5. Tillad kameraet, når du starter et scan.

## Mini3DScan

Den lille test-app ligger stadig i repoet og bygges af [Build unsigned IPA](.github/workflows/build-ipa.yml).

https://github.com/gustavfriborg/Mini3Dscan/releases/download/latest/Mini3DScan.ipa

Bundle-id: `dk.friborg.mini3dscan`. Den viser et ARKit-trådnet og kan gemme én OBJ-fil. Uden LiDAR viser den en dansk besked.

## Byg

[Build HouseCapture IPA](.github/workflows/build-house-capture.yml) kører på GitHubs `xcode-27`-runner ved push til `main` eller `cursor/**`, og når det startes manuelt. Det checker `apps/house-capture` ud på det fastgjorte commit, genererer Xcode-projektet med XcodeGen 2.46.0, bygger til `iphoneos` uden codesign og pakker `Payload/HouseCapture.app` som `HouseCapture.ipa`.

## MIT-licens for 3D Model Anything

Kildekoden til HouseCapture er skrevet af Wes Bos og udgivet under MIT-licensen. Denne tekst skal følge med, når appen distribueres:

```
MIT License

Copyright (c) 2026 Wes Bos

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Upstream-licensen siger desuden, at filer under `data/` og `docs/images/thumb-1.png` ikke er dækket af MIT. De indgår ikke i dette build.
