function update-fish-functions
    set -l repo (dirname (dirname (readlink -f (status --current-filename))))
    git -C $repo fetch origin
    git -C $repo pull
    fish $repo/install.fish
end
