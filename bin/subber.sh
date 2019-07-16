#!/bin/bash

## A shell script to extract vob subtitles and transform them to srt subtitles

VSTREAMID="11";
SUBTID="10";

while getopts hv:s: option
do
case "${option}"
in
v) VSTREAMID=${OPTARG};;
s) SUBTID=${OPTARG};;
esac
done

DATE=`date "+%D/%H/%M"`;
TMPDIR="/tmp/subber/"$DATE;
DVDDEV="/dev/dvd";

mkdir -p $TMPDIR;
ls -la $TMPDIR;

mencoder -nocache -noslices -noconfig all -o /dev/null -nosound -of rawaudio -ovc copy -vobsubout "$TMPDIR/$SUBTID.subvob" -vobsuboutindex 0 -sid $SUBTID -dvd-device $DVDDEV dvd://$VSTREAMID;

subp2tiff --normalize "$TMPDIR/$SUBTID.subvob";
find "$TMPDIR" -name "$SUBTID.*.tif" | while read -r fname ; do tesseract $fname $fname -l deu ; done;
subptools -s -t srt -n lf -i "$TMPDIR/$SUBTID.subvob.xml" -o "$TMPDIR/$SUBTID.subvob.srt";
ls -la $TMPDIR;

