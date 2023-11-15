function emoji-grid --argument NAME --argument SIZE --description 'Makes a large emoji for use in slack'
    if test -d $SIZE 
        set $SIZE 3x3
    end
    set -l DIMS (string split "x" $SIZE)
    set -l OUT (mktemp)
    set -l i 1
    for y in (seq 1 $DIMS[2])
        set -l LINE ""
        for x in (seq 1 $DIMS[1])
            set LINE "$LINE:$NAME$i:"
            set i (math $i + 1)
        end
        echo $LINE
        echo $LINE >> $OUT
    end
    cat $OUT | pbcopy
    echo (set_color -i grey)Copied to clipboard!
    rm -rf $OUT
end