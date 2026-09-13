# LibNK

UI- und Werkzeugbibliothek für nkUI, LibMap und LibQB.

**Fork von LibEKL 1.0.6.** LibEKL wird nicht umgebaut und nicht beschnitten; sie bleibt
unverändert installiert und bedient ihre bestehenden Verbraucher weiter (unter anderem
nkDebug). LibNK hat einen eigenen Identifier und eine eigene globale Tabelle, beide
laufen daher konfliktfrei nebeneinander.

## Stand

Der Fork startet **API-identisch** zu LibEKL. Der Umstieg eines Verbrauchers ist deshalb
ein Namenswechsel, kein Verhaltenswechsel — je Datei eine Zeile:

```lua
local LibEKL = LibNK
```

Rückweg: diese Zeile löschen.

## Eingebettet: der Verbraucher stellt die Schriften

Rift löst Asset-Pfade nur im Verzeichnisbaum des **Host-Addons** auf, und dessen
`Libs/` ist davon ausgenommen. Eine eingebettete Bibliothek erreicht ihre eigenen
mitgelieferten Dateien deshalb **nicht** — ihre Addon-Id ist gültig, ihr Code läuft,
aber der Client findet nichts. Gemessen am 13.09.2026 mit `LibNK` in `nkUI/Libs`:

| unter `nkUI` registriert | Ergebnis |
|---|---|
| `fonts/nkUI-Montserrat-SemiBold.ttf` | zeichnet |
| `Libs/LibNK/fonts/LibNK-Montserrat-SemiBold.ttf` | zeichnet nicht |
| `nkUI/Libs/LibNK/fonts/LibNK-Montserrat-SemiBold.ttf` | zeichnet nicht |

Der Verbraucher sagt deshalb einmal beim Start, unter welcher Id seine Schriften
liegen:

```lua
LibNK.UI.SetAssetOwner(addonInfo.id)
```

Danach beschriftet LibNK seine eigenen Widgets aus dieser Registry. Erwartet werden
die Namen, die auch `main.lua` registriert: `Montserrat`, `MontserratSemiBold`,
`MontserratBold`, `FiraMono`, `FiraMonoBold`, `FiraMonoMedium`. Fehlt einer, meldet
`UI.SetFont` das einmal je Kombination im Chat.

Ohne den Aufruf bleibt es bei der eigenen Id — **eigenständig ändert sich nichts**,
und der `fonts/`-Ordner wird weiter gebraucht. Eingebettet ist er totes Gewicht;
entfernt wird er trotzdem nicht, weil eine Lib laut Bauprinzip auch allein laufen
können soll.

## Nicht übernommen

Ohne Referenz in nkUI, LibMap oder LibQB (nachgezählt, Stand 12.09.2026):

| Modul | Begründung |
|---|---|
| `ui/grid/*` | einziger Verbraucher ist nkDebug, das auf LibEKL bleibt |
| `ui/form/colorPicker.lua` | 0 Verbraucher |
| `tools/date_time.lua` | 0 Verbraucher |
| `tools/performance.lua` | 0 Verbraucher; die Queue hatte nie einen Nutzer |
| `Libs/LibUnitChange` | LibMap bringt eine eigene Kopie mit |
| `locales/localizationRU.lua` | Supportentscheidung, kein Nullverbraucher — der Fallback ist EN |
| `unit/`, `cooldown/`, `inventory/` | werden durch LibUnit, LibCooldown und LibInventory ersetzt |

Der Frame-Treiber rief `processAbilityCooldowns`, `processItemCooldowns` und
`processPerformanceQueue` auf; alle drei liegen in nicht übernommenen Modulen und sind
entfernt.

## Prüfung ohne Spiel

```sh
luajit test-load.lua              # laedt alle RunOnStartup-Dateien gegen einen Rift-Stub
luajit test-setfont.lua           # UI.SetFont: benennt die Ursache, wirft aber nie
../check-lua-compat.sh .          # Syntax nicht neuer als Lua 5.1
```
