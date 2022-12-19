function save-token --description 'Save token' --argument NAME --argument TOKEN
  echo $TOKEN > ~/.tokens/$NAME
  sudo chown root ~/.tokens/$NAME
  sudo chmod 600  ~/.tokens/$NAME
end
