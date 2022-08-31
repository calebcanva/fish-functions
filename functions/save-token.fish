function save-token --description 'Save token' --argument token --argument name
  echo $token > (string join "" "~/.tokens/" $name)
end
