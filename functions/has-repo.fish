function has-repo
    if not test (git rev-parse --is-inside-work-tree 2> /dev/null)
        getopts $argv | while read -l key value
            switch $key
                case s silent
                case '*'
                    echo (set_color -i grey)'Not a git repository. Exiting...'
            end
        end
        return 1
    end
end
