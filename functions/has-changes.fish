function has-changes
    git update-index --refresh 2>/dev/null
    if test -z (not git diff-index --quiet HEAD -- 2>/dev/null)
        return 0
    end
    return 1
end
