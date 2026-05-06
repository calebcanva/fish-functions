function wt-clean --description "Remove worktrees for branches already merged into green"
    set -l canva_root "$HOME/work/canva"

    if not test -d $canva_root
        echo "Error: $canva_root not found"
        return 1
    end

    # Fetch to get latest remote state
    echo "→ Fetching origin..."
    git -C $canva_root fetch origin --prune --quiet

    set -l removed 0
    set -l skipped 0

    # Get all worktrees (skip the first one — that's the main checkout)
    set -l worktrees (git -C $canva_root worktree list --porcelain | grep ^worktree | awk '{print $2}')

    for wt_path in $worktrees
        # Skip the main checkout
        if test "$wt_path" = $canva_root
            continue
        end

        set -l branch (git -C $wt_path branch --show-current 2>/dev/null)
        if test -z "$branch"
            continue
        end

        # Check if branch is merged into origin/green
        set -l merge_base (git -C $canva_root merge-base origin/green $branch 2>/dev/null)
        set -l branch_tip (git -C $canva_root rev-parse $branch 2>/dev/null)

        if test "$merge_base" = "$branch_tip"
            echo "→ Merged: $branch ($wt_path)"
            read -l -P "   Remove? [y/N] " confirm
            if test "$confirm" = y -o "$confirm" = Y
                git -C $canva_root worktree remove $wt_path --force
                git -C $canva_root branch -d $branch 2>/dev/null
                set removed (math $removed + 1)
                echo "   Removed."
            else
                set skipped (math $skipped + 1)
            end
        else
            # Check if remote branch is gone (PR merged via squash)
            if not git -C $canva_root ls-remote --heads origin $branch | grep -q $branch
                echo "→ Remote gone: $branch ($wt_path)"
                read -l -P "   Remove? [y/N] " confirm
                if test "$confirm" = y -o "$confirm" = Y
                    git -C $canva_root worktree remove $wt_path --force
                    git -C $canva_root branch -D $branch 2>/dev/null
                    set removed (math $removed + 1)
                    echo "   Removed."
                else
                    set skipped (math $skipped + 1)
                end
            end
        end
    end

    echo ""
    echo "Done. Removed: $removed  Skipped: $skipped"
end
