function timestamp --description 'Generates a timestamp with the format YYYYMMDD-HHMMSS'
  echo (date +%Y%m%d-%H%M%S) $argv; 
end
