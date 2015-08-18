#! /bin/bash

ROOT="$HOME/hdd"
DOWNLOAD="$ROOT/downloads"
MOVIES="$ROOT/videos/movies"
TVSHOWS="$ROOT/videos/tvshows"

SUPPORTED_EXTENSIONS="mp4 avi m4v mkv mov"
NAME_BLACKLIST="vostfr|720p|1080p"

if [ ! -d $DOWNLOAD ]
then
    mkdir -p $DOWNLOAD
fi

if [ ! -d $MOVIES ]
then
    mkdir -p $MOVIES
fi

if [ ! -d $TVSHOWS ]
then
    mkdir -p $TVSHOWS
fi

function check_extension {
    found=0
    ar=($SUPPORTED_EXTENSIONS)
    for el in "${ar[@]}"; do
        if [ $el = "$1" ]
        then
            found=1
            break;
        fi
    done
    if [ $found -ne 1 ]
    then
        echo 404
    else
        echo 0
    fi
}

function extract_cpasbien {
    name=`echo $1 | sed -e "s/.*\\.cpasbien\\..*\\] \(.*\)/\1/gI"`
    echo $name
}

function is_tvshows {
    if [[ $1 =~ ^.*[sS][0-9]+[eE][0-9]+.*$ ]]
    then
        echo 0
    else
        echo 1
    fi
}

function extract_tvshow_name {
    show=$([[ $1 =~ ^(.*)[\\.-][sS][0-9]+[eE][0-9]+.*$ ]] && echo ${BASH_REMATCH[1]} | sed -r 's/\.|-/ /g')
    show=${show,,}
    show=${show^}
    echo $show | sed -r "s/$NAME_BLACKLIST//g" | sed -e 's/[[:space:]]*$//'
}

function extract_season {
    season=$([[ $1 =~ ^.*[\\.-][sS]([0-9]+)[eE][0-9]+.*$ ]] && echo ${BASH_REMATCH[1]} | sed -r 's/\.|-/ /g')
    season=${season,,}
    season=${season^}
    echo $((10#$season))
}

function extract_episode {
    episode=$([[ $1 =~ ^.*[\\.-][sS][0-9]+[eE]([0-9]+).*$ ]] && echo ${BASH_REMATCH[1]} | sed -r 's/\.|-/ /g')
    episode=${episode,,}
    episode=${episode^}
    echo $((10#$episode))
}

for file in $DOWNLOAD/*
do
    filename=$(basename "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"
    
    filename=$(extract_cpasbien "$filename")

    if [ $(check_extension $extension) -ne 0 ]
    then
        >&2 echo "Error: non supported extension: $extension"
        continue
    fi
    
    if [ $(is_tvshows $filename) -eq 0 ]
    then
        show=$(extract_tvshow_name "$filename")
        season=$(extract_season "$filename")
        episode=$(extract_episode "$filename")
        path_to_move="$TVSHOWS/$show/Season $season"
        if [ $season -lt 10 ]
        then
            season="0${season}"
        fi
        if [ $episode -lt 10 ]
        then
            episode="0${episode}"
        fi
        finalname=$(echo $show | sed -e "s/ /./g")".s${season}e${episode}.${extension}"
        
        if [ ! -d "$path_to_move" ]
        then
            mkdir -p "$path_to_move"
        fi
        
        echo "Moving $file -> $path_to_move/$finalname"
        if [ ! -f "$path_to_move/$finalname" ]
        then
            mv "$file" "$path_to_move/$finalname"
        else
            >&2 echo "Error: Cannot move file '$file': destination '$path_to_move/$finalname' already exists"
        fi
    else
        path_to_move="$MOVIES"
        finalname="$filename.$extension"
        
        if [ ! -f "$path_to_move/$finalname" ]
        then
            mv "$file" "$path_to_move/$finalname"
        else
            >&2 echo "Error: Cannot move file '$file': destination '$path_to_move/$finalname' already exists"
        fi
    fi
    
done