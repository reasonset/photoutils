#!/bin/zsh

typeset ALBUM_NAME=${PWD:t}
typeset DESTDIR=../../photo-thumb/by-album/"$ALBUM_NAME"
if [[ ! -e $DESTDIR ]]
then
  mkdir -pv $DESTDIR || exit 2
fi

typeset PU_THUMBNAIL_SIZE=360x360

if [[ -e ${XDG_CONFIG_DIR:-$HOME/.config}/reasonset/photoutils.rc ]]
then
  source ${XDG_CONFIG_DIR:-$HOME/.config}/reasonset/photoutils.rc
fi


# Compress to AVIF image.
for i in *.(jpg|JPG|jpeg|JPEG)
do
  avifenc "$i" "${i:r}.avif" || exit 2
done

# Move original image for converting to thumbnail.
mv -v *.(jpg|JPG|jpeg|JPEG) $DESTDIR || exit 2

# Work in thumbnail directory
cd $DESTDIR
mogrify -resize $PU_THUMBNAIL_SIZE *.(jpg|JPG|jpeg|JPEG)
jpegoptim *.(jpg|JPG|jpeg|JPEG)
