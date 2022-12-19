function token --description 'Get token' --argument TOKEN
    sudo cat (string join "" ~/.tokens/ $TOKEN)
end
