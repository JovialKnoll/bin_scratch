#!/bin/bash

#show usage
ERR="usage: arc [-a] 7z-file [directory-of-files]"
if [ "$#" == "0" ] || [ "$1" == "--help" ];
then
    echo "$ERR"
    exit 0
fi

#get values
ALL=false
DIR="."
if [ "$1" == "-a" ];
then
    ALL=true
    shift
fi
case "$#" in
2)
    DIR="$2"
    ;&
1)
    ZFILE="$1"
    ;;
*)
    echo "$ERR"
    exit 1
    ;;
esac

#check values
if ! [ -d "$DIR" ];
then
    echo "$ERR"
    exit 1
fi
if ! [[ $ZFILE == *.7z ]];
then
    ZFILE+=.7z
fi

#get files to archive
FILES=""
for ENTRY in "$DIR"/*
do
    #only use files that are not archives of this type
    if [ -f "$ENTRY" ] && ! [[ $ENTRY == *.7z ]];
    then
        DONE=false
        if [ "$ALL" = true ];
        then
            FILES+=" \"$ENTRY\""
            DONE=true
        fi
        while [ "$DONE" = false ];
        do
            read -er -n 1 -p "$ENTRY (y/n) "
            if [[ $REPLY =~ ^[yY]$ ]];
            then
                FILES+=" \"$ENTRY\""
                DONE=true
            else if [[ $REPLY =~ ^[nN]$ ]];
            then
                DONE=true
            fi fi
        done
    fi
done

#archive files
COMMAND="7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on $ZFILE$FILES"
eval $COMMAND
exit 0
