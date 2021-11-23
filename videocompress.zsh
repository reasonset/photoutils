#!/bin/zsh

typeset -g PU_VIDEODIR=$(xdg-user-dir VIDEOS)
if [[ -z $PU_VIDEODIR ]]
then
  PU_VIDEODIR=$HOME/Videos
fi
typeset -i PU_VP9CRF=30
typeset -i PU_X265CRF=23
typeset PU_OPUSABR=128k

if [[ -e ${XDG_CONFIG_DIR:-$HOME/.config}/reasonset/photoutils.rc ]]
then
  source ${XDG_CONFIG_DIR:-$HOME/.config}/reasonset/photoutils.rc
fi

if whence -f pu_video_path > /dev/null
then
  pu_video_path
fi

typeset album="${PWD:t}"
typeset DESTDIR=$PU_VIDEODIR/by-album/$album

typeset -A opts
zparseopts -D -A opts -- -usevp9 -usex265 -vp9crf: -x265crf: -opusabr: -destdir:

if [[ -n "${opts[(i)--usevp9]}" ]]
then
  PU_USEVP9=yes
fi

if [[ -n "${opts[(i)--usex265]}" ]]
then
  PU_USEVP9=no
fi

if [[ -n "${opts[--vp9crf]}" ]]
then
  PU_VP9CRF="${opts[--vp9crf]}"
fi

if [[ -n "${opts[--x265crf]}" ]]
then
  PU_X265CRF="${opts[--x265crf]}"
fi

if [[ -n "${opts[--opusabr]}" ]]
then
  PU_OPUSABR="${opts[--opusabr]}"
fi

if [[ -n "${opts[--destdir]}" ]]
then
  DESTDIR="${opts[--destdir]}"
fi


for i in *.(mp4|mkv|mov|MOV|webm)
do
  if [[ ! -e $DESTDIR ]]
  then
    mkdir -pv $DESTDIR
  fi
  vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$i")
  acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$i")
  #frate=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$i")

  #OPTIONS SETUP
  typeset vsyncopt
  typeset videoopt=()
  if [[ ( $vcodec == h26* && $PU_USEVP9 != yes ) || ( $vcodec == vp* && $PU_USEVP9 == yes ) ]]
  then
    vsyncopt=passthrough
  else
    vsyncopt=vfr
  fi
  if [[ $PU_USEVP9 == yes ]]
    then
    case $acodec in
      ("")
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libvpx-vp9 -crf $PU_VP9CRF -an $DESTDIR/${i:r}.webm|| exit 2
        ;;
      aac)
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libvpx-vp9 -crf $PU_VP9CRF -c:a copy $DESTDIR/${i:r}.mkv || exit 2
        ;;
      opus)
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libvpx-vp9 -crf $PU_VP9CRF -c:a copy $DESTDIR/${i:r}.webm || exit 2
        ;;
      *)
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libvpx-vp9 -crf $PU_VP9CRF -c:a libopus -b:a $PU_OPUSABR $DESTDIR/${i:r}.mkv || exit 2
        ;;
    esac
  else
    case $acodec in
      ("")
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libx265 -crf $PU_X265CRF -an $DESTDIR/${i:r}.mp4 || exit 2
        ;;
      aac)
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libx265 -crf $PU_X265CRF -c:a copy $DESTDIR/${i:r}.mp4 || exit 2
        ;;
      opus)
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libx265 -crf $PU_X265CRF -c:a copy $DESTDIR/${i:r}.mkv || exit 2
        ;;
      *)
        ffmpeg -n -i $i -vsync $vsyncopt -c:v libx265 -crf $PU_X265CRF -c:a libopus -b:a $PU_OPUSABR $DESTDIR/${i:r}.mkv || exit 2
        ;;
    esac  
  fi
done

rm -v *.(mp4|mkv|mov|MOV|webm)
