function has-changes
    git update-index --refresh
    return (not git diff-index --quiet HEAD --)
end
