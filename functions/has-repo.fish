function has-repo
    if not test (git rev-parse --is-inside-work-tree 2> /dev/null)
        echo (set_color -i grey)'Not a git repository. Exiting...'
        return 1
    end
end
