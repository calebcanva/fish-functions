function freshen --description 'Freshen the current branch from the latest green'
  git fetch origin green && git merge --no-edit origin/green && git push;
end
