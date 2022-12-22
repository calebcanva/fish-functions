function play-sound --argument NAME
    set -l SOUND (echo -n (find -E ~/.config/fish -regex '.*\.(mp3|wav)' | grep $NAME))
    if not test (count $SOUND) -eq 1
        if test (count $SOUND) -lt 1
            echo "No sound file found for $NAME"
        else
            echo "Too many files found: $SOUND"
        end
        return 1
    end
    if test -f $SOUND
        afplay $SOUND >/dev/null 2>&1 &
    end
end
