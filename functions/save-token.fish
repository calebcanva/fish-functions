function save-token --description 'Save token' --argument NAME --argument TOKEN
  echo $TOKEN > ~/.tokens/$NAME
end
