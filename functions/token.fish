function token --description 'Get token' --argument TOKEN
  cat (string join "" ~/.tokens/ $TOKEN); 
end
