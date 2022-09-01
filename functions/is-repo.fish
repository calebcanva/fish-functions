function is-repo
    if test (git rev-parse --is-inside-work-tree 2> /dev/null)
        return 0
    else
        return 1
    end
end
