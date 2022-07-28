function cb --description 'Checkout branch' --argument branch
    set -l current_branch (git branch --show-current)
    if test $branch = $current_branch
        echo "Already checked out "(set_color green)$branch(set_color normal)"..."
        return 0
    end
    echo "Checking out "(set_color green)$branch(set_color normal)
    git checkout $branch
end
