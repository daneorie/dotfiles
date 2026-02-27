#!/bin/zsh

karabiner=(~/.config/karabiner.edn)

cd ~/dotfiles/karabiner/

echo "{" > $karabiner
cat setup.edn >> $karabiner
echo >> $karabiner
echo ":main [" >> $karabiner
#cat spaceCadetShifts.edn >> $karabiner
#echo >> $karabiner
cat spaceFn.edn >> $karabiner
echo >> $karabiner
#cat colemak.edn >> $karabiner
#echo >> $karabiner
cat kindaVim.edn >> $karabiner
echo >> $karabiner
cat hyperMeh.edn >> $karabiner
echo >> $karabiner
cat misc.edn >> $karabiner
echo "] ;; main" >> $karabiner
echo "} ;; EOF">> $karabiner

goku
