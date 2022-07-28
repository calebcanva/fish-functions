set -l pr_train_commands merge new-branch checkout
complete -f -c pr-train -n "not __fish_seen_subcommand_from $pr_train_commands" -a merge -d 'Merges each branch from origin/green to the tail'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $pr_train_commands" -a new-branch -d 'Creates a new tail branch'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $pr_train_commands" -a checkout -d 'Checkout the head/tail/nth branch'
complete -f -c pr-train -n "not __fish_seen_subcommand_from $pr_train_commands" -a update-prs -d 'Create & Update PR\'s'