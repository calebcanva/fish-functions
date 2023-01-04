function slugify
    string lower (string replace -r -- '--+' '-' (string replace -r -a "[^a-z0-9]" "-" (string replace -r -a "^[^a-z0-9]+|[^a-z0-9]+\$" "" $argv)))
end
