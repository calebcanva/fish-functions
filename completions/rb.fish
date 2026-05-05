function __git-branches
    git branch &>/dev/null
    if test $status -eq 0
        git branch --format "%(refname:short)"
    end
end

# Complete OLD_BRANCH (first arg) — only when no args have been given yet
complete -f -c rb -n "not __fish_seen_subcommand_from (__git-branches)" -a "(__git-branches)" -d 'Old branch name'

# Complete NEW_BRANCH (second arg) — once OLD_BRANCH has been specified
complete -f -c rb -n "__fish_seen_subcommand_from (__git-branches)" -a "(__git-branches)" -d 'New branch name'
