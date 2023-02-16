function remoji
    set -l EMOJIS
    for EMOJI in (string split "  " (cat (dirname (status --current-filename))/emojis.txt))
        set -a EMOJIS $EMOJI
    end
    echo (random choice $EMOJIS)
end