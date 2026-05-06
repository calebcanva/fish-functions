function wt-new --description "Create a new Canva worktree and open a Claude Code session"
    if test (count $argv) -eq 0
        echo "Usage: wt-new <name-or-ticket> [slug]"
        echo "  wt-new my-feature"
        echo "  wt-new PWIT-1234"
        echo "  wt-new PWIT-1234 text-wrap"
        return 1
    end

    set -l input (string lower $argv[1])
    set -l slug ""
    if test (count $argv) -ge 2
        set slug (string lower $argv[2])
    end

    # Detect Jira ticket format (e.g. PWIT-1234, DETG-99)
    if string match -qr '^[a-z]+-[0-9]+$' $input
        if test -n "$slug"
            set -l branch "caleb-$input-$slug"
        else
            set -l branch "caleb-$input"
        end
    else
        set -l branch "caleb-$input"
    end

    set -l worktree_path "$HOME/work/canva-$branch"
    set -l canva_root "$HOME/work/canva"

    if not test -d $canva_root
        echo "Error: $canva_root not found"
        return 1
    end

    echo "→ Creating worktree at $worktree_path on branch $branch"

    # Fetch latest green
    echo "→ Fetching origin/green..."
    git -C $canva_root fetch origin green --quiet

    # Create the worktree from origin/green
    git -C $canva_root worktree add -b $branch $worktree_path origin/green
    if test $status -ne 0
        echo "Error: failed to create worktree"
        return 1
    end

    # Run pnpm install
    echo "→ Running pnpm install..."
    pnpm --dir $worktree_path install --frozen-lockfile --prefer-offline --reporter=silent

    echo "→ Opening Claude Code session in $worktree_path"
    cd $worktree_path
    otter claude-code --add-dir ~/work/skynet
end
