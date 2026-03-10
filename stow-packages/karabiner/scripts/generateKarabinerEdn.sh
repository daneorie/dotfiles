#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
karabiner="$SCRIPT_DIR/../.config/karabiner.edn"

echo "{" > "$karabiner"
cat "$SCRIPT_DIR/setup.edn" >> "$karabiner"
echo >> "$karabiner"
echo ":main [" >> "$karabiner"
#cat "$SCRIPT_DIR/spaceCadetShifts.edn" >> "$karabiner"
#echo >> "$karabiner"
cat "$SCRIPT_DIR/spaceFn.edn" >> "$karabiner"
echo >> "$karabiner"
cat "$SCRIPT_DIR/colemak.edn" >> "$karabiner"
echo >> "$karabiner"
#cat "$SCRIPT_DIR/kindaVim.edn" >> "$karabiner"
#echo >> "$karabiner"
cat "$SCRIPT_DIR/hyperMeh.edn" >> "$karabiner"
echo >> "$karabiner"
cat "$SCRIPT_DIR/misc.edn" >> "$karabiner"
echo "] ;; main" >> "$karabiner"
echo "} ;; EOF" >> "$karabiner"

goku
