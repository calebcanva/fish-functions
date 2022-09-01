cd (dirname (status --current-filename))
for dir in "functions" "completions"
    set -l files (ls $dir | grep '.fish\|.mp3')
    for file in $files
        ln -s (pwd)/$dir/$file ~/.config/fish/$dir/$file
    end
end