function emojicommit
    git add .
    git commit -a -m "$(remoji) $argv"
end
