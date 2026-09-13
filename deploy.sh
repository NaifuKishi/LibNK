#!/usr/bin/env bash
# Kopiert LibNK in die eingebettete Kopie unter nkUI/Libs. Mit --reload wird
# anschliessend /reloadui ausgeloest (riftctl).
#
# LibNK ist ein Submodul von nkUI und wird mit nkUI ausgeliefert, nicht daneben.
# Eine zweite, eigenstaendige Kopie unter Addons/LibNK traege denselben
# Identifier und waere ein Doppelpfad - genau das, was bei LibMap und LibQB
# aufgeraeumt wurde.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
DOCS="${RIFTCTL_DOCS:-$HOME/Games/Heroic/Prefixes/Glyph/pfx/drive_c/users/steamuser/Documents/RIFT}"
ADDONS="$DOCS/Interface/Addons"
[ -d "$ADDONS" ] || { echo "Addon-Verzeichnis nicht gefunden: $ADDONS (RIFTCTL_DOCS setzen)"; exit 1; }

TARGET="$ADDONS/nkUI/Libs/LibNK"
[ -d "$ADDONS/nkUI" ] || { echo "nkUI ist nicht deployt: $ADDONS/nkUI"; exit 1; }

if [ -d "$ADDONS/LibNK" ]; then
  echo "Warnung: $ADDONS/LibNK existiert noch - zweiter Identifier 'LibNK'." >&2
fi

rm -rf "$TARGET"
mkdir -p "$TARGET"
cp -r "$HERE/LibNK/." "$TARGET/"
rm -rf "$TARGET/.git"
echo "deployt: $TARGET"

if [ "${1:-}" = "--reload" ]; then
  RIFTCTL="$HERE/../debug/riftctl.sh"
  [ -x "$RIFTCTL" ] && "$RIFTCTL" reload || echo "riftctl nicht gefunden, bitte /reloadui manuell"
fi
