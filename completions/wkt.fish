function __git-worktree-completions
    git worktree list &>/dev/null
    if test $status -eq 0
        set -l worktrees (git worktree list)
        set -l i 1
        for wt in $worktrees
            set -l path (string split ' ' $wt)[1]
            set -l branch (string split ' ' $wt)[-1]
            echo "$i\t$path ($branch)"
            set i (math $i + 1)
        end
    end
end

complete -f -c wkt -n "not __fish_seen_subcommand_from (__git-worktree-completions)" -a "(__git-worktree-completions)"
