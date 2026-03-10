#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
karabiner="$SCRIPT_DIR/../.config/karabiner.edn"
cd "$SCRIPT_DIR" || { echo "Failed to change directory to $SCRIPT_DIR" >&2; exit 1; }

echo "{" > $karabiner
cat setup.edn >> $karabiner
echo >> $karabiner
echo ":main [" >> $karabiner
cat spaceCadetShifts.edn >> $karabiner
echo >> $karabiner
cat spaceFn.edn >> $karabiner
echo >> $karabiner
cat colemakHomeRowMods.edn >> $karabiner
echo >> $karabiner
cat hyperMeh.edn >> $karabiner
echo >> $karabiner
cat misc.edn >> $karabiner
echo "] ;; main" >> $karabiner
echo "} ;; EOF">> $karabiner

goku
