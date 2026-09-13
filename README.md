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
luajit test-load.lua LibNK        # laedt alle RunOnStartup-Dateien gegen einen Rift-Stub
luajit test-setfont.lua           # UI.SetFont: benennt die Ursache, wirft aber nie
../check-lua-compat.sh LibNK      # Syntax nicht neuer als Lua 5.1
```
