function db --wraps='git branch -D' --description 'alias db git branch -D'
  git branch -D $argv; 
end
