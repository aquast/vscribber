#!/bin/bash

## A shell script to copy and convert DVD Titles into mkv

VSTREAMID="11";
SUBTID="10";
DATE=`date "+%D-%H-%M"`;

while getopts hv:s: option
do
case "${option}"
in
v) VSTREAMID=${OPTARG};;
s) SUBTID=${OPTARG};;
esac
done

TMPDIR="/tmp/subber/"$DATE;
DVDDEV="/dev/dvd";

mkdir -p $TMPDIR;
ls -la $TMPDIR;

## Copy Video with all its parts to temp-Dir
mplayer dvd://$VSTREAMID -v -dumpstream -dumpfile $TMPDIR/$VSTREAMID.vob
mplayer $TMPDIR/$VSTREAMID.vob -v -aid 130 -dumpaudio -dumpfile $TMPDIR/DE.aac
mplayer $TMPDIR/$VSTREAMID.vob -v -aid 128 -dumpaudio -dumpfile $TMPDIR/EN.aac
mplayer $TMPDIR/$VSTREAMID.vob -v -aid 129 -dumpaudio -dumpfile $TMPDIR/FR.aac

ffmpeg -hwaccel cuvid -i $TMPDIR/$VSTREAMID.vob -c:v h264_nvenc -profile:v main -level 4.1 -map 0:0 $TMPDIR/$VSTREAMID.avi

mencoder -nocache -noslices -noconfig all -o /dev/null -nosound -of rawaudio -ovc copy -vobsubout "$TMPDIR/$SUBTID.subvob" -vobsuboutindex 0 -sid $SUBTID -dvd-device $DVDDEV dvd://$VSTREAMID;

subp2tiff --normalize "$TMPDIR/$SUBTID.subvob";
find "$TMPDIR" -name "$SUBTID.*.tif" | while read -r fname ; do tesseract $fname $fname -l deu ; done;
subptools -s -t srt -n lf -i "$TMPDIR/$SUBTID.subvob.xml" -o "$TMPDIR/$SUBTID.subvob.srt";


mkvmerge -o $TMPDIR/$VSTREAMID.mkv $TMPDIR/$VSTREAMID.avi  --sync 0:850 $TMPDIR/DE.aac $TMPDIR/EN.aac $TMPDIR/FR.aac $TMPDIR/$SUBTID.subvob.srt


