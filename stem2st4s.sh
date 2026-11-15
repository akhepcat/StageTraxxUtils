#!/bin/bash
TRACKS=0

#export songs from original zipfile
exportzip() {
	file="${1}"
	SONGFILE="${file//.zip}"
	
	genuuid "${SONGFILE}" && SONG_UUID="${UUID}"
	SUFFIX=${SONG_UUID%%-*}
	STEMDIR="${SONGFILE}_${SUFFIX}"
	mkdir "${STEMDIR}"
	unzip -J songs.zip -d "${STEMDIR}"
	# we need the number of stem tracks later
	TRACKS=$( find "${STEMDIR}" -type f -iname "*.mp3" | wc -l | awk '{print $1}')
	# make the stemfile filenames match the outer zipfile name for consistency
	( cd "${STEMDIR}" && rename "s/.*_(.*)\.mp3/${SONGFILE}_$1.mp3/" ./* )
}

#get length in secs
getsonglen() {
    file="${1}"
    if [ -r "${file}" ]; then
        LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${file}")
    fi
}

#generate a consistent UUID for each filename
genuuid() {
    file="${1}"
    UUID=$(uuidgen -n @url --sha1 -N "${file}")
}


# writes the whole json file by looping over the stemfiles and building the structure.
write_json() {
    declare -a TRACK_COLORS
    declare -A TRACK_STEMS

    TRACK_COLORS=( 1103805914635 1103792268267 1103790913921 1103790257876 1103799559096 1103805498436 1103805498436 )
    TRACK2BUS=( lead-vocals=1 backing-vocals=2 guitar=3 bass=4 drums=5 piano=6 other=7 )
    BUS2TRACK=( 1=lead-vocals 2=backing-vocals 3=guitar 4=bass 5=drums 6=piano 7=other )
    STEM_NAMES=( lead-vocals="vox" backing-vocals="bgvox" guitar="guitar" bass="bass" drums="drums" piano="piano" other="others" )

    # Get the song length from the lead vocals stem track
    STEM_NAME="${BUS2TRACK[1]}"
    STEMFILEP="${STEMDIR}/${SONG_FILE}_${STEM_NAME}.mp3"

    output="share_data.json"
    TS=$(date -u  '+%Y-%m-%dT%H:%M:%SZ')
    genuuid "${SONGFILE}" && SONG_UUID="${UUID}"
    gensonglen "${STEMFILEP}" && SONG_LEN="${LENGTH}"

    cat <<EOF | tee $output
{
  "metadata": {
    "created": "${TS}",
    "type": "full",
    "version": "4.1"
  },
  "folders": [],
  "keywords": [],
  "playlistKeywords": [],
  "playlists": [],
  "playlistSongs": [],
  "regions": [],
  "songKeywords": [],
  "songs": [
    {
      "id": "${SONG_UUID}",
      "title": "${SONG_FILE##*-}",
      "artist": "${SONG_FILE%%-*}",
      "bpm": 120,
      "duration": ${SONG_LEN},
      "added": "${TS}",
      "lastModified": "${TS}",
      "volume": 0.0,
      "pitch": 0,
      "speed": 1.0,
      "color": 0,
      "beatAnchorTime": 0.0,
      "capo": 0,
      "countInBeats": 4,
      "chordTranspose": 0,
      "endTime": ${SONG_LEN},
      "fadeIn": 0.0,
      "fadeOut": 0.0,
      "fontSize": 22,
      "metronomeMode": 0,
      "metronomeType": 2,
      "pitchToChords": true,
      "playCount": 0,
      "scrollSpeed": 1.2,
      "startTime": 0.0,
      "timecodeOffset": 0.0,
      "tune": 0,
      "lyrics": ""
    }
  ],
  "tracks": [
EOF

#  write the track info

CLOSEBKT=""

for (( TRACK=1; TRACK<TRACKS; TRACK++ ))
do
    STEMFILEP="${STEMDIR}/${SONG_FILE}"
    genuuid "${STEMFILEP##*/}" && TRACK_ID=${UUID}

    if [ ${TRACK} -gt 1 ]
    then
    	CLOSEBKT="},"
    fi

    STEM_NAME="${BUS2TRACK[$TRACK]}"

cat <<EOF | tee -a $output
    ${CLOSEBKT}
    {
      "id": "${TRACK_ID}",
      "songID": "${SONG_UUID}",
      "name": "${STEM_NAMES[$STEM]}",
      "number": ${TRACK},
      "filePath": "${STEMFILEP}_${STEM_NAME}.mp3",
      "bus": ${TRACK2BUS[$STEM]},
      "volume": 0.0,
      "mute": false,
      "pan": 0.0,
      "equalizer": {
        "bypass": false,
        "bands": [
          {
            "bw": 1,
            "freq": 100,
            "gain": 0.0,
            "label": "LO",
            "type": 1
          },
          {
            "bw": 1,
            "freq": 500,
            "gain": 0.0,
            "label": "LM",
            "type": 0
          },
          {
            "bw": 2,
            "freq": 2000,
            "gain": 0.0,
            "label": "HM",
            "type": 0
          },
          {
            "bw": 1,
            "freq": 10000,
            "gain": 0.0,
            "label": "HI",
            "type": 2
          }
        ]
      },
      "duration": ${SONG_LEN},
      "color": ${TRACK_COLORS[$TRACK]},
      "hasMarkers": false,
      "lastModified": "${TS}",
      "muteGroupMask": 0,
      "transpose": false
EOF
done

# print the trailer, with the final closing bracket from the stemfiles
cat <<EOF | tee -a $output
    }
  ]
}
EOF

# all done
}

if [ -n "$1" -a -r "$1" ]
then
    ZIPFILE="${1}"

    exportzip ZIPFILE
    write_json
fi
