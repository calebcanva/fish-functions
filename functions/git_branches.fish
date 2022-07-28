function git_branches
    git branch &> /dev/null
    if test $status -eq 0
        git branch --format "%(refname:short)"
    end
end
