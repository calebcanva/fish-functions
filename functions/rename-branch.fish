function rename-branch --argument old_branch --argument new_branch
    echo (set_color green)(string join (set_color normal)' > '(set_color green) $old_branch $new_branch)
    read -P (set_color red)"Press enter to continue ⏎"(set_color normal)
    if test $status -gt 0
        return $status
    end
    git branch -m $old_branch $new_branch # Rename branch locally    
    git push origin :$old_branch # Delete the old branch    
    git push --set-upstream origin $new_branch # Push the new branch, set local branch to track the new remote
end
