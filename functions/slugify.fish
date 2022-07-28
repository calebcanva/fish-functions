function slugify
    string lower (string join '-' (string split ' ' (string trim $argv)))
end
