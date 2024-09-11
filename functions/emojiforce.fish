function emojiforce
    git commit -a -m "$(remoji) $argv" && git push origin HEAD --force
end