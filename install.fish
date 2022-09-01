cd (dirname (status --current-filename))
for DIR in functions completions
    echo (set_color normal)"Installing $DIR:"
    set -l FILES (ls $DIR | grep '.fish\|.mp3')
    echo (set_color green)(string join (set_color normal)", "(set_color green) $FILES)(set_color normal)"."
    for FILE in $FILES
        ln -s (pwd)/$DIR/$FILE ~/.config/fish/$DIR/$FILE 2>/dev/null
    end
    set -l ALL_FILES (ls ~/.config/fish/$DIR/)
    for FILE in $ALL_FILES
        set -l LINKED_FILE (readlink -f ~/.config/fish/$DIR/$FILE)
        # Remove symlinks that don't work any more
        if not test -f $LINKED_FILE
            rm -f ~/.config/fish/$DIR/$FILE
        end
    end
end
echo (set_color -i grey)"Done..."