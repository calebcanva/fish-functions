function save-token --description 'Save token' --argument name --argument token
  echo $token > ~/.tokens/$name
end
