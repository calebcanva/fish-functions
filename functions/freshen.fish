function freshen --description 'Freshen the current branch from the latest master'
    if pr-train --exists --silent
        echo (set_color -i grey)Pr train detected...(set_color normal)
        git fetch origin master && pr-train merge
    else
        echo (set_color -i grey)Going to merge the latest master...(set_color normal)
        git fetch origin master && git merge --no-edit origin/master && git push
    end
end
