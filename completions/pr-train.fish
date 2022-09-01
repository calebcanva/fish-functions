set -l CMDS merge new-branch checkout update-prs
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a merge -d 'Merges each branch from origin/green to the tail'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a new-branch -d 'Creates a new tail branch'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a checkout -d 'Checkout the head/tail/nth branch'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a update-prs -d 'Create & Update PR\'s'