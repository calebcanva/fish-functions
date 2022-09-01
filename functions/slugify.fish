function slugify
    string lower (string replace -r -- '--+' '-' (string join '-' (string split ' ' (string trim $argv))))
end
