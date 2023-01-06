function has-pr --argument BRANCH --argument STATUSES
    set -l RES 1
    for STATUS in (string split "," $STATUSES)
        if not test (echo (gh pr list --head $BRANCH --state $STATUS)) = ""
            set RES 0
        end
    end
    return $RES
end