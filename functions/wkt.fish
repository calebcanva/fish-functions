function wkt --argument NUM
    set -l WORKTREES (git worktree list)
    if test "$NUM" = ""
        echo $WORKTREES
        return 0
    end
    if test $NUM -lt 1;
        echo (set_color -i grey) "Worktree not found..."
        return 1
    end
    if test $NUM -gt (count $WORKTREES);
        echo (set_color -i grey) "Worktree not found..."
        return 1
    end
    set -l WORKTREE $WORKTREES[$NUM]
    cd (string split ' ' $WORKTREE)[1]
end