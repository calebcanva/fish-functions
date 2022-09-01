function rename-branch --argument OLD_BRANCH --argument NEW_BRANCH
    echo (set_color green)(string join (set_color normal)' > '(set_color green) $OLD_BRANCH $NEW_BRANCH)
    read -P (set_color red)"Press enter to continue ⏎"(set_color normal)
    if test $status -gt 0
        return $status
    end
    git branch -m $OLD_BRANCH $NEW_BRANCH # Rename branch locally    
    git push origin :$OLD_BRANCH # Delete the old branch    
    git push --set-upstream origin $NEW_BRANCH # Push the new branch, set local branch to track the new remote
end
