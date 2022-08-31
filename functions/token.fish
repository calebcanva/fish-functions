function token --description 'Get token' --argument token
  cat (string join "" ~/.tokens/ $token); 
end
