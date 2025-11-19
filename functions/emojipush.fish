function emojipush
    git add .
    git commit -a -m "$(remoji) $argv" && git push origin HEAD
end
