#! /bin/bash

if [ $# -ne 1 ]
then
    >&2 echo "Error: you must pass one file as argument"
    echo "usage: $0 files-to-create"
fi

ROOT="/home/ubuntu/hdd/downloads"

while read line
do
    if [ ! -f "$ROOT/$line" ]
    then
        touch "$ROOT/$line"
    fi
done < $1
