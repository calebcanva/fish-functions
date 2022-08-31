function git-repo --description 'Get current repo name <username>/<repo>'
    string match -r -i '[a-z0-9-]+/[a-z0-9-]+' (git config --get remote.origin.url)
end