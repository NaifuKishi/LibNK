#!/usr/bin/env bash
# Kopiert LibNK ins Rift-Addon-Verzeichnis. Mit --reload wird anschliessend
# /reloadui ausgeloest (riftctl).
#
# Waehrend der Migration laeuft LibNK als eigenstaendiges Addon neben LibEKL;
# beide tragen verschiedene Identifier und koexistieren konfliktfrei.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
DOCS="${RIFTCTL_DOCS:-$HOME/Games/Heroic/Prefixes/Glyph/pfx/drive_c/users/steamuser/Documents/RIFT}"
ADDONS="$DOCS/Interface/Addons"
[ -d "$ADDONS" ] || { echo "Addon-Verzeichnis nicht gefunden: $ADDONS (RIFTCTL_DOCS setzen)"; exit 1; }

rm -rf "$ADDONS/LibNK"
mkdir -p "$ADDONS/LibNK"
cp -r "$HERE/LibNK/." "$ADDONS/LibNK/"
rm -rf "$ADDONS/LibNK/.git"
echo "deployt: $ADDONS/LibNK"

if [ "${1:-}" = "--reload" ]; then
  RIFTCTL="$HERE/../debug/riftctl.sh"
  [ -x "$RIFTCTL" ] && "$RIFTCTL" reload || echo "riftctl nicht gefunden, bitte /reloadui manuell"
fi
