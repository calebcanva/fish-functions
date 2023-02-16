set -l CMDS merge new-branch checkout update-prs
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a init -d 'Creates a new PR train'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a new-branch -d 'Creates a new tail branch'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a merge -d 'Merges each branch from origin/green to the tail'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a checkout -d 'Checkout the head/tail/nth branch'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a update-prs -d 'Create & Update PR\'s'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a --status -d 'Check the current PR train'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a delete -d 'Deletes the current PR train'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $CMDS" -a open-config -d 'Open the PR train config file'