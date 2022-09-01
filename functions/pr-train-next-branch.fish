function pr-train-next-branch --argument BRANCH
    set -l BRANCH_PARTS (string split - $BRANCH)
    if test (string match -r "[0-9]+" $BRANCH_PARTS[-1])
        set NEXT_BRANCH (string join - $BRANCH_PARTS[1..-2])"-"(math $BRANCH_PARTS[-1] + 1)
    else
        set NEXT_BRANCH (string join - $BRANCH_PARTS)"-1"
    end
    echo $NEXT_BRANCH
end
