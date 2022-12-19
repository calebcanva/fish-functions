function db --description 'Delete branch' --argument BRANCH
    git branch -D $BRANCH
end
