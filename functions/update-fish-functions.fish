function update-fish-functions
    set -l repo (dirname (dirname (readlink -f (status --current-filename))))
    git -C $repo fetch origin
    git -C $repo pull
    fish $repo/install.fish
    for f in ~/.config/fish/functions/*.fish
        source $f
    end
    echo (set_color -i grey)"Shell re-sourced."
end
