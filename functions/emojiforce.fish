function emojiforce
    git add .
    git commit -a -m "$(remoji) $argv" && git push origin HEAD --force
end
