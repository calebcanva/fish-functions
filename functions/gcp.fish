function gcp
    git commit -a -m "$(remoji) $argv" && git push origin HEAD
end
