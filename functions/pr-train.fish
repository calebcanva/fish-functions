function __pr-train-next-branch --argument BRANCH
    set -l BRANCH_PARTS (string split - $BRANCH)
    if test (string match -r "[0-9]+" $BRANCH_PARTS[-1])
        set NEXT_BRANCH (string join - $BRANCH_PARTS[1..-2])"-"(math $BRANCH_PARTS[-1] + 1)
    else
        set NEXT_BRANCH (string join - $BRANCH_PARTS)"-1"
    end
    echo $NEXT_BRANCH
end

function __pr-train-simple --argument PR_LIST_INFO CURRENT_BRANCH
    set -a STR "<pr-train>"
    set -a STR "\n"
    set -a STR "\n### PRs"
    set -a STR "\n"
    for i in (seq 0 (math (echo $PR_LIST_INFO | jq '. | length') - 1))
        set -l PR_BRANCH (echo $PR_LIST_INFO | jq -r .[$i].headRefName)
        set -l PR_NUMBER (echo $PR_LIST_INFO | jq -r .[$i].number)
        if test (string match $CURRENT_BRANCH $PR_BRANCH)
            set -a STR "\n"(printf -- "- #%s 👈" $PR_NUMBER)
        else
            set -a STR "\n"(printf -- "- #%s" $PR_NUMBER)
        end
    end
    set -a STR "\n"
    set -a STR "\n</pr-train>"
    echo $STR
end

function __pr-train-table --argument PR_LIST_JSON --argument CURRENT_BRANCH
    set -a STR "<pr-train>"
    set -a STR "\n"
    set -a STR "\n### PR Train 🚂"
    set -a STR "\n"
    set -a STR "\n| PR | Description |   |"
    set -a STR "\n| -- | ------ | - |"
    for i in (seq 0 (math (echo $PR_LIST_JSON | jq '. | length') - 1))
        set -l BRANCH_NAME (echo $PR_LIST_JSON | jq -r .[$i].headRefName)
        set -l PR_TITLE (string replace -r -i '\[[A-Z]+(-[0-9]*)*\]' '' (echo $PR_LIST_JSON | jq -r .[$i].title))
        set -l PR_URL (echo $PR_LIST_JSON | jq -r .[$i].url)
        set -l PR_NUMBER (echo $PR_LIST_JSON | jq -r .[$i].number)
        if test (string match $CURRENT_BRANCH $BRANCH_NAME)
            set -a STR "\n"(printf "| #%s | [%s](%s) | %s |" $PR_NUMBER $PR_TITLE $PR_URL "👈")
        else
            set -a STR "\n"(printf "| #%s | [%s](%s) |    |" $PR_NUMBER $PR_TITLE $PR_URL)
        end
    end
    set -a STR "\n"
    set -a STR "\n</pr-train>"
    echo $STR
end

function pr-train --argument TYPE --argument MODIFIER
    # Check if repo exists
    if not test (git rev-parse --is-inside-work-tree 2> /dev/null)
        echo (set_color -i grey)'Not a git repository. Exiting...'
        return 1
    end
    set -l BASE_DIR "$HOME/.pr-train"
    if not test -d $BASE_DIR
        echo (set_color -i grey)Creating directory: $BASE_DIR(set_color normal)
        mkdir $BASE_DIR
    end
    set -l GIT_REPO (git-repo)
    set -l BASE_REPO_DIR "$BASE_DIR/$GIT_REPO"
    if not test -d $BASE_REPO_DIR
        echo (set_color -i grey)Creating directory: $BASE_REPO_DIR(set_color normal)
        mkdir -p $BASE_REPO_DIR
    end
    begin
        set -l CURRENT_BRANCH (git branch --show-current)
        set -l CURRENT_BRANCH_DIR "$BASE_REPO_DIR/$CURRENT_BRANCH"
        set -l PR_TRAIN_BRANCHES_FILE (readlink -f "$CURRENT_BRANCH_DIR/pr-train-branches")
        # If no file or symlink is found, just set the path to the future file
        if test $status -gt 0
            set PR_TRAIN_BRANCHES_FILE "$CURRENT_BRANCH_DIR/pr-train-branches"
        end
        switch $TYPE
            case init
                # Check for existing config
                if test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color grey)"PR train already exists at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    return 0
                end
                mkdir $CURRENT_BRANCH_DIR
                set -l BRANCHES (string join " " (git branch --contains $CURRENT_BRANCH --format "%(refname:short)"))
                # Add head config
                printf $BRANCHES >$PR_TRAIN_BRANCHES_FILE
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                set -l PR_TRAIN_BRANCHES_PRINT (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                set -l -p PR_TRAIN_BRANCHES_PRINT origin/green

                echo (set_color normal)"The following PR train will be created"
                # Print out new PR train info
                echo (set_color green)(string join (set_color normal)" > "(set_color green) $PR_TRAIN_BRANCHES_PRINT)
                read -P (set_color grey)"Are you sure you want to continue? ⏎"(set_color normal)
                if test $status -gt 0
                    return $status
                end

                set -l PR_TRAIN_BRANCHES_REST $PR_TRAIN_BRANCHES[2..-1]
                # Add symlinks to found branches
                for BRANCH in $PR_TRAIN_BRANCHES_REST
                    set -l THIS_BRANCH_DIR "$BASE_REPO_DIR/$BRANCH"
                    mkdir $THIS_BRANCH_DIR
                    ln -s "$PR_TRAIN_BRANCHES_FILE" "$THIS_BRANCH_DIR/pr-train-branches"
                end
                play-sound train-whistle
            case open-config
                # Check for existing config
                if not test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color grey)"No PR train exits at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    return 0
                end
                open -- $PR_TRAIN_BRANCHES_FILE
            case status
                # Check for existing config
                if not test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color grey)"No PR train exits at $CURRENT_BRANCH_DIR."(set_color normal)
                    return 0
                end
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                # Count before prepending green branch
                set -l BRANCH_COUNT (count $PR_TRAIN_BRANCHES)
                set -l -p PR_TRAIN_BRANCHES origin/green
                if test $BRANCH_COUNT -eq 1
                    echo "🚂 1 branch in train:"
                else
                    echo "🚂 $BRANCH_COUNT branches in train:"
                end
                echo (set_color green)(string join (set_color normal)" > "(set_color green) $PR_TRAIN_BRANCHES)
            case delete
                # Check for existing config
                if not test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color grey)"No PR train exits at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    return 0
                end
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                set -l -p PR_TRAIN_BRANCHES origin/green
                echo (set_color normal)"The following PR train will be deleted"
                echo (set_color green)(string join (set_color normal)" > "(set_color green) $PR_TRAIN_BRANCHES)
                read -P (set_color grey)"Are you sure you want to continue? ⏎"(set_color normal)
                if test $status -gt 0
                    return $status
                end
                # Delete all branches pr-train config
                for BRANCH in $PR_TRAIN_BRANCHES
                    rm -rf "$BASE_REPO_DIR/$BRANCH"
                end
            case new-branch
                # Check for existing config
                if not test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color grey)"No PR train exits at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    return 0
                end
                set -l DEFAULT_BRANCH_NAME (__pr-train-next-branch $CURRENT_BRANCH)
                read -P "Enter a branch name "(set_color grey)"($DEFAULT_BRANCH_NAME)"(set_color normal)": "(set_color green) NEW_BRANCH_NAME
                if test $status -gt 0
                    return 0
                end
                set -l NEW_BRANCH_NAME (string trim (slugify "$NEW_BRANCH_NAME"))
                # Check for empty input
                if test -z $NEW_BRANCH_NAME
                    set NEW_BRANCH_NAME $DEFAULT_BRANCH_NAME
                end
                echo ""(set_color normal)"This will create a new branch "(set_color green)"$NEW_BRANCH_NAME"(set_color normal)" from branch "(set_color green)$CURRENT_BRANCH(set_color normal)
                read -P (set_color -i grey)"Press enter to continue ⏎"(set_color normal)
                if test $status -gt 0
                    return 0
                end
                git checkout -b $NEW_BRANCH_NAME $CURRENT_BRANCH
                if test $status -gt 0
                    return 0
                end
                set -l NEW_BRANCH_DIR "$BASE_REPO_DIR/$NEW_BRANCH_NAME"

                # Write new branch to head file
                set -l PR_TRAIN_BRANCHES (cat $PR_TRAIN_BRANCHES_FILE)
                echo $PR_TRAIN_BRANCHES $NEW_BRANCH_NAME >$PR_TRAIN_BRANCHES_FILE
                # Add symlink to new branch dir
                mkdir $NEW_BRANCH_DIR
                ln -s "$PR_TRAIN_BRANCHES_FILE" "$NEW_BRANCH_DIR/pr-train-branches"
            case checkout
                # Check for existing config
                if not test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color -i grey)"No PR train exits at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    return 0
                end
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                switch $MODIFIER
                    case 0 head start
                        cb $PR_TRAIN_BRANCHES[1]
                    case -1 tail end
                        cb $PR_TRAIN_BRANCHES[-1]
                    case '*'
                        if test (string match -r "[0-9]+" $MODIFIER)
                            set -l INDEX (math "$MODIFIER + 1")
                            if test $INDEX -gt (count $PR_TRAIN_BRANCHES)
                                echo (set_color red)"'"$MODIFIER"' exceeds the number of branches. Did you mean '"(math (count $PR_TRAIN_BRANCHES) - 1)"'?"
                                return 1
                            end
                            cb $PR_TRAIN_BRANCHES[$INDEX]
                        else
                            echo (set_color red)"'"$MODIFIER"' is not a number. Exiting..."
                        end
                end
            case merge
                # Check for existing config
                if not test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color grey)"No PR train exits at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    return 0
                end
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                set -p PR_TRAIN_BRANCHES origin/green
                # Check if we are continuing a pr-train merge
                if test "$MODIFIER"
                    switch $MODIFIER
                        case continue # Find the current index and merge from there
                            set PR_TRAIN_BRANCHES $PR_TRAIN_BRANCHES[(contains -i (git branch --show-current) $PR_TRAIN_BRANCHES)..-1]
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
                            set PR_TRAIN_BRANCHES $PR_TRAIN_BRANCHES[2..-1]
                        case '*'
                            if test (string match -r "[0-9]+" $MODIFIER)
                                set PR_TRAIN_BRANCHES $PR_TRAIN_BRANCHES[(math $MODIFIER + 1)..-1]
                            else
                                echo (set_color red)"'"$MODIFIER"' is not a number. Exiting..."
                                return 1
                            end
                    end
                end
                if test (count $PR_TRAIN_BRANCHES) -gt 1
                    echo "Going to merge "(count $PR_TRAIN_BRANCHES)" branches:"
                else
                    echo (set_color grey)"Already at tail. Exiting..."
                    return 0
                end
                echo (set_color green)(string join (set_color normal)' > '(set_color green) $PR_TRAIN_BRANCHES)
                read -P (set_color red)"Press enter to continue ⏎"(set_color normal)
                if test $status -gt 0
                    return $status
                end
                # Start merge loop
                if set -q PR_TRAIN_BRANCHES
                    # Create sequence from 1 to the length of branches, loop through
                    for i in (seq (math (count $PR_TRAIN_BRANCHES) - 1))
                        # Set the current branch index to merge into
                        set -l j (math $i + 1)
                        # Checkout the head branch
                        echo "Checking out $PR_TRAIN_BRANCHES[$j]"
                        git checkout -q $PR_TRAIN_BRANCHES[$j]
                        # Merge the previous branch into current (default starts at green)
                        echo "Merging $PR_TRAIN_BRANCHES[$i] into $PR_TRAIN_BRANCHES[$j]"
                        git merge -q --no-edit $PR_TRAIN_BRANCHES[$i]
                        if test $status -gt 0
                            echo (set_color red)"Conflicts during merge... Please resolve them and continue."
                            return $status
                        end
                        echo (set_color -i grey)"Pushing..."(set_color normal)
                        git push
                    end
                    echo (set_color -i grey)"Done 🚉"
                    play-sound train-whistle
                else
                    echo (set_color -i grey)"No branches found for '$PR_TRAIN_BRANCHES'. Exiting..."
                end
            case update-prs
                # Check for existing config
                if not test -f $PR_TRAIN_BRANCHES_FILE
                    echo (set_color -i grey)"No PR train exits at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    return 0
                end
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                if set -q PR_TRAIN_BRANCHES
                    # Set default base to master
                    set -p PR_TRAIN_BRANCHES master
                    set -l NEW_PR_CREATED false
                    for i in (seq (math (count $PR_TRAIN_BRANCHES) - 1))
                        # Set the current branch index to merge into
                        set -l j (math $i + 1)
                        set -l BASE_BRANCH $PR_TRAIN_BRANCHES[$i]
                        set -l BRANCH $PR_TRAIN_BRANCHES[$j]
                        # Check if a branch already exists
                        if test (echo (gh pr list --head $BRANCH --state open)) = ""
                            if test (echo (gh pr list --head $BRANCH --state merged)) = ""
                                set NEW_PR_CREATED true
                                echo "Creating PR for "(set_color green)$BRANCH(set_color normal)" with base "(set_color green)$BASE_BRANCH(set_color normal)"..."
                                gh pr create --draft --title (string replace -a "-" " " $BRANCH) --body "<pr-train></pr-train>" --base $BASE_BRANCH --head $BRANCH
                            else
                                echo (set_color grey)"PR already exists for $BRANCH"(set_color normal)
                            end
                        else
                            echo (set_color grey)"PR already exists for $BRANCH"(set_color normal)
                        end
                    end
                    echo (set_color grey)"Updating descriptions..."(set_color normal)
                    if test $NEW_PR_CREATED = true
                        # Delay list fetch so that newly created PR's appear
                        sleep 3
                    end
                    # Get new PR list again
                    # TODO: Change to use number instead
                    set -l PR_LIST_OPEN (gh pr list --state open --author "@me" --head $PR_TRAIN_BRANCHES[1] --json number --json title --json body --json url --json headRefName)
                    set -l PR_LIST_MERGED (gh pr list --state merged --author "@me" --head $PR_TRAIN_BRANCHES[1] --json number --json title --json body --json url --json headRefName)
                    # Join the two arrays since gh doesn't support multiple statuses in a single request
                    set -l PR_LIST_JSON (jq -n "$PR_LIST_OPEN + $PR_LIST_MERGED")
                    set -l PR_LIST_SORTED (echo $PR_LIST_JSON | jq 'sort_by(.headRefName) | .')
                    set -l TMP_DIR "$BASE_DIR/tmp/"
                    mkdir $TMP_DIR
                    for i in (seq 0 (math (echo $PR_LIST_SORTED | jq '. | length') - 1))
                        set -l PR_TABLE_CURRENT_BRANCH (echo $PR_LIST_SORTED | jq -r .[$i].headRefName)
                        set -l PR_NUMBER (echo $PR_LIST_SORTED | jq -r .[$i].number)
                        echo "Updating PR: "$PR_NUMBER
                        # Write old body to tmp file
                        echo -e (echo $PR_LIST_SORTED | jq -r .[$i].body) >$TMP_DIR"old-body-"$PR_NUMBER".txt"
                        # Write pr-train table to tmp file
                        switch $MODIFIER
                            case simple
                                echo -e (__pr-train-simple (echo $PR_LIST_SORTED) $PR_TABLE_CURRENT_BRANCH) >$TMP_DIR"table-"$PR_NUMBER".txt"
                            case '*'
                                echo -e (__pr-train-table (echo $PR_LIST_SORTED) $PR_TABLE_CURRENT_BRANCH) >$TMP_DIR"table-"$PR_NUMBER".txt"
                        end
                        # Write new body to tmp file
                        if test (string match -r "<pr-train>.*</pr-train>" (cat $TMP_DIR"old-body-"$PR_NUMBER".txt" | tr '\n' '\b'))
                            string replace -r "<pr-train>.*</pr-train>" (cat $TMP_DIR"table-"$PR_NUMBER".txt" | tr '\n' '\b') (cat $TMP_DIR"old-body-"$PR_NUMBER".txt" | tr '\n' '\b') | tr '\b' '\n' >$TMP_DIR"new-body-"$PR_NUMBER".txt"
                        else
                            cat $TMP_DIR"old-body-"$PR_NUMBER".txt" >$TMP_DIR"new-body-"$PR_NUMBER".txt"
                            cat $TMP_DIR"table-"$PR_NUMBER".txt" >>$TMP_DIR"new-body-"$PR_NUMBER".txt"
                        end
                        # Edit PR with new body 
                        gh pr edit $PR_NUMBER -F $TMP_DIR"new-body-"$PR_NUMBER".txt"
                    end
                    # Clean up tmp files
                    rm -rf $TMP_DIR
                else
                    echo (set_color grey)"No branches found for '$PR_TRAIN_BRANCHES'. Exiting..."
                end
            case '*'
                if test -d $TYPE
                    echo (set_color red)"Unknown option: "(set_color grey)"<empty>"
                else
                    echo (set_color red)"Unknown option: $TYPE"
                end
        end
    end
end
