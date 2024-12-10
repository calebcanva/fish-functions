function save-token --description 'Save token' --argument NAME --argument TOKEN
  if test -f filename
      sudo chown (whoami) ~/.tokens/$NAME
      sudo chmod u+w ~/.tokens/$NAME
  end
  echo $TOKEN >~/.tokens/$NAME
  sudo chown root ~/.tokens/$NAME
  sudo chmod 600 ~/.tokens/$NAME
end
