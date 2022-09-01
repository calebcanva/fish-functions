function cb --description 'Checkout branch' --argument BRANCH
    set -l CURRENT_BRANCH (git branch --show-current)
    if test "$BRANCH" = "$CURRENT_BRANCH"
        echo "Already checked out "(set_color green)$BRANCH(set_color normal)"..."
        return 0
    end
    echo "Checking out "(set_color green)$BRANCH(set_color normal)
    git checkout $BRANCH
end
