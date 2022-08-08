function pr-train --argument pr_train_type pr_train_modifier
    begin
        switch $pr_train_type
            case merge
                set -l pr_train_branches (git_branches | grep (pr_train_head_branch_name))
                set -p pr_train_branches 'origin/green'
                # Check if we are continuing a pr-train merge
                if test $pr_train_modifier
                    switch $pr_train_modifier
                        case continue # Find the current index and merge from there
                            set pr_train_branches $pr_train_branches[(contains -i (git branch --show-current) $pr_train_branches)..-1]
                            # Check if an existing merge is still in progress
                            if test -f .git/MERGE_HEAD
                                read -P (set_color yellow)"Merge in progress. Continue? ⏎"(set_color normal)
                                if test $status -gt 0
                                    return $status
                                end
                                git merge --continue
                                if test $status -gt 0
                                    return $status
                                end
                                git push
                            end
                        case head # Skip green
                            set pr_train_branches $pr_train_branches[2..-1]
                        case '*'
                            if test (string match -r "[0-9]+" $pr_train_modifier)
                                set pr_train_branches $pr_train_branches[(math $pr_train_modifier + 1)..-1]
                            else
                                echo (set_color red)"'"$pr_train_modifier"' is not a number. Exiting..."
                                return 1
                            end
                    end
                end
                if test (count $pr_train_branches) -gt 1
                    echo "Going to merge "(count $pr_train_branches)" branches:"
                else
                    echo (set_color grey)"Already at tail. Exiting..."
                    return 0
                end
                echo (set_color green)(string join (set_color normal)' > '(set_color green) $pr_train_branches)
                read -P (set_color red)"Press enter to continue ⏎"(set_color normal)
                if test $status -gt 0
                    return $status
                end
                # Start merge loop
                if set -q pr_train_branches
                    # Create sequence from 1 to the length of branches, loop through
                    for i in (seq (math (count $pr_train_branches) - 1))
                        # Set the current branch index to merge into
                        set -l j (math $i + 1)
                        # Checkout the head branch
                        echo "Checking out $pr_train_branches[$j]"
                        git checkout -q $pr_train_branches[$j]
                        # Merge the previous branch into current (default starts at green)
                        echo "Merging $pr_train_branches[$i] into $pr_train_branches[$j]"
                        git merge --no-edit $pr_train_branches[$i]
                        if test $status -gt 0
                            echo (set_color red)"Conflicts during merge... Please resolve them and continue."
                            return $status
                        end
                        echo (set_color grey)"Pushing..."
                        git push
                    end
                else
                    echo (set_color grey)"No branches found for '$pr_train_branches'. Exiting..."
                end
            case new-branch
                echo "This will create a new branch "(set_color green)(pr_train_next_branch_name)(set_color normal)
                read -P (set_color red)"Press enter to continue ⏎"(set_color normal)
                if test $status -gt 0
                    return 0
                end
                git checkout -b (pr_train_next_branch_name)
            case checkout
                switch $pr_train_modifier
                    case 0 head
                        set -l pr_train_head (pr_train_head_branch_name)
                        cb $pr_train_head
                    case -1 tail
                        set -l pr_train_tail (pr_train_tail_branch_name)
                        cb $pr_train_tail
                    case '*'
                        if test (string match -r "[0-9]+" $pr_train_modifier)
                            set -l pr_train_branch_to_checkout (pr_train_head_branch_name)"-$pr_train_modifier"
                            cb $pr_train_branch_to_checkout
                        else
                            echo (set_color red)"'"$pr_train_modifier"' is not a number. Exiting..."
                        end
                end
            case update-prs
                set -l pr_train_branches (git_branches | grep (pr_train_head_branch_name))
                # Set default base to master
                set -p pr_train_branches 'master'
                set -l new_pr_created false
                if set -q pr_train_branches
                    for i in (seq (math (count $pr_train_branches) - 1))
                        # Set the current branch index to merge into
                        set -l j (math $i + 1)
                        set -l base_branch $pr_train_branches[$i]
                        set -l branch $pr_train_branches[$j]
                        # Check if a branch already exists
                        if test (echo (gh pr list --head $branch --state open)) = ""
                            if test (echo (gh pr list --head $branch --state merged)) = ""
                                set new_pr_created true
                                echo "Creating PR for "(set_color green)$branch(set_color normal)" with base "(set_color green)$base_branch(set_color normal)"..."
                                gh pr create --draft --title (string replace -a "-" " " $branch) --body "<pr-train></pr-train>" --base $base_branch --head $branch
                            else
                                echo (set_color grey)"PR already exists for $branch"(set_color normal)
                            end
                        else
                            echo (set_color grey)"PR already exists for $branch"(set_color normal)
                        end
                    end
                    echo (set_color grey)"Updating descriptions..."(set_color normal)
                    if test $new_pr_created = true
                        # Delay list fetch so that newly created PR's appear
                        sleep 3
                    end
                    # Get new PR list again
                    # TODO: Change to use number instead
                    set -l pr_train_pr_list_json_open (gh pr list --state open --author "@me" --head (pr_train_head_branch_name) --json number --json title --json body --json url --json headRefName)
                    set -l pr_train_pr_list_json_merged (gh pr list --state merged --author "@me" --head (pr_train_head_branch_name) --json number --json title --json body --json url --json headRefName)
                    # Join the two arrays since gh doesn't support multiple statuses in a single request
                    set -l pr_train_pr_list_json (jq -n "$pr_train_pr_list_json_open + $pr_train_pr_list_json_merged")
                    set -l pr_train_pr_list_sorted (echo $pr_train_pr_list_json | jq 'sort_by(.headRefName) | .')
                    set -l tmp './.pr-train-tmp/'
                    mkdir $tmp
                    for i in (seq 0 (math (echo $pr_train_pr_list_sorted | jq '. | length') - 1))
                        set -l pr_train_table_current_branch (echo $pr_train_pr_list_sorted | jq -r .[$i].headRefName)
                        set -l pr_train_pr_number (echo $pr_train_pr_list_sorted | jq -r .[$i].number)
                        echo "Updating PR: "$pr_train_pr_number
                        # Write old body to tmp file
                        echo -e (echo $pr_train_pr_list_sorted | jq -r .[$i].body) > $tmp"old-body-"$pr_train_pr_number".txt"
                        # Write pr-train table to tmp file
                        switch $pr_train_modifier
                            case 'simple'
                                echo -e (pr_train_table_simple (echo $pr_train_pr_list_sorted) $pr_train_table_current_branch) > $tmp"table-"$pr_train_pr_number".txt"
                            case '*'
                                echo -e (pr_train_table (echo $pr_train_pr_list_sorted) $pr_train_table_current_branch) > $tmp"table-"$pr_train_pr_number".txt"
                        end
                        # Write new body to tmp file
                        string replace -r "<pr-train>.*</pr-train>" "(cat $tmp"table-"$pr_train_pr_number".txt")" "(cat $tmp"old-body-"$pr_train_pr_number".txt")" > $tmp"new-body-"$pr_train_pr_number".txt"
                        # Edit PR with new body 
                        gh pr edit $pr_train_pr_number -F $tmp"new-body-"$pr_train_pr_number".txt"
                    end
                    # Clean up tmp files
                    rm -rf $tmp
                else
                    echo (set_color grey)"No branches found for '$pr_train_branches'. Exiting..."
                end
            case '*'
                echo (set_color red)"Unknown option: $pr_train_type"
        end
    end
end
