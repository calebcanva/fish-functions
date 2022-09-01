function play-sound --argument NAME
    set -l SOUND (dirname (status --current-filename))"/$NAME.mp3"
    if test -f $SOUND
        afplay $SOUND >/dev/null 2>&1 &
    end
end
