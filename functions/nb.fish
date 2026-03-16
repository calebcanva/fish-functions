function nb --description 'Create a fresh branch off default remote branch'
    set -l BRANCH_NAME
    if set -q argv[1]
        set BRANCH_NAME (string join " " $argv)
    else
        read -l -P 'Branch name: ' BRANCH_NAME
    end
    if not test -n "$BRANCH_NAME"
        echo "Branch name missing. Exiting..."
        return 1
    end
    # Detect remote default branch (e.g. origin/main)
    set -l BASE_REF (git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
    if not test -n "$BASE_REF"
        set BASE_REF origin/master
    end
    echo (set_color -i grey)"Fetching latest from origin..."(set_color normal)
    git fetch origin --prune; or return $status
    set -l FULL_BRANCH_NAME (slugify "caleb-$BRANCH_NAME")
    echo "Checking out new branch $FULL_BRANCH_NAME from $BASE_REF"
    git checkout --no-track -b "$FULL_BRANCH_NAME" "$BASE_REF"
end
