function freshen --description 'Freshen the current branch from the latest green'
    if pr-train --exists --silent
        echo (set_color -i grey)Pr train detected...(set_color normal)
        git fetch origin green && pr-train merge
    else
        echo (set_color -i grey)Going to merge the latest green...(set_color normal)
        git fetch origin green && git merge --no-edit origin/green && git push
    end
end
