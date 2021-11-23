#!/bin/zsh

cd "$1"

PU_EDITOR=xed
PU_TERMINAL=(gnome-terminal --)

if [[ -e ${XDG_CONFIG_DIR:-$HOME/.config}/reasonset/photoutils.rc ]]
then
  source ${XDG_CONFIG_DIR:-$HOME/.config}/reasonset/photoutils.rc
fi

case "$(zenity --height=300 --list --title="Photoutils by Reasonset" --column="Action" "Compress album" "Compress video" "CV - Use VP9" "CV - HEVC CRF27" "CV - VP9 CRF36" "Update DB" "Write tag")" in 
  "Compress album")
    exec $PU_TERMINAL photocompress.zsh
    ;;
  "Compress video")
    exec $PU_TERMINAL videocompress.zsh
    ;;
  "CV - Use VP9")
    exec $PU_TERMINAL videocompress.zsh --usevp9
    ;;
  "CV - HEVC CRF27")
    exec $PU_TERMINAL videocompress.zsh --usex265 --x265crf 27
    ;;
  "CV - VP9 CRF36")
    exec $PU_TERMINAL videocompress.zsh --usevp9 --vp9crf 36
    ;;  
  "Update DB")
    if [[ ! -e index.qdbm && -e ../index.qdbm ]]
    then
      cd ..
    fi
    exec phototag-update.rb
    ;;
  "Write tag")
    exec $PU_EDITOR .tags
    ;;
esac
