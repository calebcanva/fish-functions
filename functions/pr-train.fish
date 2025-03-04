#prettier-ignore
function __pr-train-help
    echo Pr train tool - made with (set_color red)❤(set_color normal) by Caleb
    echo
    echo (set_color normal --bold) '  pr-train init:'
    echo (set_color normal) '    Initilises a new PR train'
    echo
    echo (set_color normal --bold) '  pr-train new-branch:'
    echo (set_color normal) '    Creates a new carriage in the train off the tail'
    echo
    echo (set_color normal --bold) '  pr-train merge:'
    echo (set_color normal) '    Merges the carriages into each other from head to tail'
    echo (set_color grey) '      --from (optional) index to start at'
    echo (set_color grey) '      --to   (optional) index to end at'
    echo (set_color grey -i) '      (or "here" to merge to/from the current branch )'
    echo
    echo (set_color normal --bold) '  pr-train checkout '(set_color -i)'n'(set_color normal --bold)':'
    echo (set_color normal) '    Checks out the nth branch in the train.'
    echo (set_color normal) '    Other values for n include:'
    echo (set_color grey -i) '      next/up     the next branch'
    echo (set_color grey -i) '      prev/down   the previous branch'
    echo (set_color grey -i) '      head        the head of the train'
    echo (set_color grey -i) '      tail        the tail of the train'
    echo
    echo (set_color normal --bold) '  pr-train prs:'
    echo (set_color normal) '    Updates/creates prs for all the branches in the current train'
    echo (set_color grey) '      --simple (optional) simpler format compared to the default table'
    echo
    echo (set_color normal --bold) '  pr-train update:'
    echo (set_color normal) '    Checks for merged branches and updates the PR train config'
    echo
    echo (set_color normal --bold) '  pr-train delete:'
    echo (set_color normal) '    Deletes the current PR train'
end

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
            set -a STR "\n"(printf "- #%s 👈" $PR_NUMBER)
        else
            set -a STR "\n"(printf "- #%s" $PR_NUMBER)
        end
    end
    set -a STR "\n"
    set -a STR "\n</pr-train>"
    echo $STR
end

function __pr-train-table --argument PR_LIST_JSON CURRENT_BRANCH
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

function pr-train --argument TYPE --argument CHECKOUT_INDEX --description "Pr-train tool"
    set -l OPTIONS h/help d/debug status e/exists ask-every-time prompt 'from=?' 'to=?' c/continue silent simple
    argparse -n pr-train $OPTIONS -- $argv
    if set -q _flag_help
        __pr-train-help
        return 0
    end
    # Check if repo exists
    has-repo
    and begin
        # Setup working vars
        set -l BASE_DIR "$HOME/.pr-train"
        if not test -d $BASE_DIR
            if not set -q _flag_silent
                echo (set_color -i grey)Creating directory: $BASE_DIR(set_color normal)
            end
            mkdir $BASE_DIR
        end
        set -l GIT_REPO (git-repo)
        set -l BASE_REPO_DIR "$BASE_DIR/$GIT_REPO"
        if not test -d $BASE_REPO_DIR
            if not set -q _flag_silent
                echo (set_color -i grey)Creating directory: $BASE_REPO_DIR(set_color normal)
            end
            mkdir -p $BASE_REPO_DIR
        end
        # Setup configuration
        set -l MAIN_BRANCH master
        set -l MERGE_BRANCH origin/green
        set -l CURRENT_BRANCH (git branch --show-current)
        set -l CURRENT_BRANCH_DIR "$BASE_REPO_DIR/$CURRENT_BRANCH"
        set -l PR_TRAIN_BRANCHES_FILE (readlink -f "$CURRENT_BRANCH_DIR/pr-train-branches.config")
        # If no file or symlink is found, just set the path to the future file
        if test $status -gt 0
            set PR_TRAIN_BRANCHES_FILE "$CURRENT_BRANCH_DIR/pr-train-branches.config"
        end
        set -l ALL_PR_TRAIN_BRANCHES_FILE (readlink -f "$CURRENT_BRANCH_DIR/all-pr-train-branches.config")
        # If no file or symlink is found, just set the path to the future file
        if test $status -gt 0
            set ALL_PR_TRAIN_BRANCHES_FILE "$CURRENT_BRANCH_DIR/all-pr-train-branches.config"
        end

        if set -q _flag_exists
            # Check for existing config
            if not test -f $PR_TRAIN_BRANCHES_FILE
                if not set -q _flag_silent
                    echo (set_color grey)"No PR train exists for $(git-repo)@$CURRENT_BRANCH. Exiting..."
                end
                return 1
            else
                return 0
            end
        end

        if set -q _flag_status
            pr-train --exists
            and begin
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                # Count before prepending green branch
                set -l BRANCH_COUNT (count $PR_TRAIN_BRANCHES)
                set -l -p PR_TRAIN_BRANCHES $MERGE_BRANCH
                if test $BRANCH_COUNT -eq 1
                    echo "🚂 1 branch in train:"
                else
                    echo "🚂 $BRANCH_COUNT branches in train:"
                end
                echo (set_color green)(string join (set_color normal)" > "(set_color green) $PR_TRAIN_BRANCHES)
            end
            return 0
        end

        switch $TYPE
            case init i
                # Check for existing config
                if test -f $PR_TRAIN_BRANCHES_FILE
                    if not set -q _flag_silent
                        echo (set_color grey)"PR train already exists at $CURRENT_BRANCH_DIR. Exiting..."(set_color normal)
                    end
                    return 0
                end
                mkdir $CURRENT_BRANCH_DIR
                set -l BRANCHES (string join " " (git branch --contains $CURRENT_BRANCH --format "%(refname:short)"))
                # Add head config
                printf $BRANCHES >$PR_TRAIN_BRANCHES_FILE
                printf $BRANCHES >$ALL_PR_TRAIN_BRANCHES_FILE
                set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                set -l PR_TRAIN_BRANCHES_PRINT (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                set -l -p PR_TRAIN_BRANCHES_PRINT $MERGE_BRANCH

                if not set -q _flag_silent
                    echo (set_color normal)"The following PR train will be created"
                    # Print out new PR train info
                    echo (set_color green)(string join (set_color normal)" > "(set_color green) $PR_TRAIN_BRANCHES_PRINT)
                    read -P (set_color grey)"Are you sure you want to continue? ⏎"(set_color normal)
                    if test $status -gt 0
                        return $status
                    end
                end

                set -l PR_TRAIN_BRANCHES_REST $PR_TRAIN_BRANCHES[2..-1]
                # Add symlinks to found branches
                for BRANCH in $PR_TRAIN_BRANCHES_REST
                    set -l THIS_BRANCH_DIR "$BASE_REPO_DIR/$BRANCH"
                    mkdir $THIS_BRANCH_DIR
                    ln -s "$PR_TRAIN_BRANCHES_FILE" "$THIS_BRANCH_DIR/pr-train-branches.config"
                    ln -s "$ALL_PR_TRAIN_BRANCHES_FILE" "$THIS_BRANCH_DIR/all-pr-train-branches.config"
                end
            case open-config oc
                pr-train --exists
                and begin
                    open -- $PR_TRAIN_BRANCHES_FILE
                end
            case update u
                pr-train --exists
                and begin
                    if not set -q _flag_silent
                        echo (set_color grey)Fetching latest $MAIN_BRANCH...(set_color normal)
                    end
                    git fetch origin $MAIN_BRANCH
                    # Check if branches are merged
                    set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                    set -l NEW_BRANCH_LIST
                    for BRANCH in $PR_TRAIN_BRANCHES
                        set -l IS_MERGED (gh pr list -H $BRANCH -s merged | grep $BRANCH)
                        if not test $IS_MERGED
                            set -a NEW_BRANCH_LIST $BRANCH
                        end
                    end
                    # Print out new PR train info
                    if not set -q _flag_silent
                        echo (set_color green)(string join (set_color normal)" > "(set_color green) $NEW_BRANCH_LIST)
                        read -P (set_color grey)"Are you sure you want to continue? ⏎"(set_color normal)
                        if test $status -gt 0
                            return $status
                        end
                    end
                    # Don't update the Full list of branches to preserve all the history
                    echo $NEW_BRANCH_LIST >$PR_TRAIN_BRANCHES_FILE
                    if not set -q _flag_silent
                        echo (set_color -i grey)"Done 🚉"
                    end
                end
            case delete d
                pr-train --exists
                and begin
                    set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                    set -l -p PR_TRAIN_BRANCHES $MERGE_BRANCH
                    if not set -q _flag_silent
                        echo (set_color normal)"The following PR train will be deleted"
                        echo (set_color green)(string join (set_color normal)" > "(set_color green) $PR_TRAIN_BRANCHES)
                        read -P (set_color grey)"Are you sure you want to continue? ⏎"(set_color normal)
                        if test $status -gt 0
                            return $status
                        end
                    end
                    # Delete all branches pr-train config
                    for BRANCH in $PR_TRAIN_BRANCHES
                        rm -rf "$BASE_REPO_DIR/$BRANCH"
                    end
                end
            case new-branch n
                pr-train --exists
                and begin
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
                    if not set -q _flag_silent
                        echo ""(set_color normal)"This will create a new branch "(set_color green)"$NEW_BRANCH_NAME"(set_color normal)" from branch "(set_color green)$CURRENT_BRANCH(set_color normal)
                        read -P (set_color -i grey)"Press enter to continue ⏎"(set_color normal)
                        if test $status -gt 0
                            return 0
                        end
                    end
                    git checkout -b $NEW_BRANCH_NAME $CURRENT_BRANCH
                    if test $status -gt 0
                        return 0
                    end
                    set -l NEW_BRANCH_DIR "$BASE_REPO_DIR/$NEW_BRANCH_NAME"

                    # Write new branch to head file
                    set -l PR_TRAIN_BRANCHES (cat $PR_TRAIN_BRANCHES_FILE)
                    echo $PR_TRAIN_BRANCHES $NEW_BRANCH_NAME >$PR_TRAIN_BRANCHES_FILE
                    echo $PR_TRAIN_BRANCHES $NEW_BRANCH_NAME >$ALL_PR_TRAIN_BRANCHES_FILE
                    # Add symlink to new branch dir
                    mkdir $NEW_BRANCH_DIR
                    ln -s "$PR_TRAIN_BRANCHES_FILE" "$NEW_BRANCH_DIR/pr-train-branches.config"
                    ln -s "$ALL_PR_TRAIN_BRANCHES_FILE" "$NEW_BRANCH_DIR/all-pr-train-branches.config"
                end
            case checkout c
                pr-train --exists
                and begin
                    set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                    # head tail start end prev next i/index
                    if test "$CHECKOUT_INDEX" = ""
                        if not set -q _flag_silent
                            echo (set_color red)"'index' not set. Exiting..."
                        end
                    end
                    switch $CHECKOUT_INDEX
                        case 0 head start
                            cb $PR_TRAIN_BRANCHES[1]
                        case -1 tail end
                            cb $PR_TRAIN_BRANCHES[-1]
                        case prev down
                            set -l INDEX (math (contains -i $CURRENT_BRANCH $PR_TRAIN_BRANCHES) - 1)
                            if test $INDEX -lt 1
                                if not set -q _flag_silent
                                    echo (set_color grey)"Already at head. Exiting..."
                                end
                                return 0
                            end
                            cb $PR_TRAIN_BRANCHES[$INDEX]
                        case next up
                            set -l INDEX (math (contains -i $CURRENT_BRANCH $PR_TRAIN_BRANCHES) + 1)
                            if test $INDEX -gt (count $PR_TRAIN_BRANCHES)
                                if not set -q _flag_silent
                                    echo (set_color grey)"Already at tail. Exiting..."
                                end
                                return 0
                            end
                            cb $PR_TRAIN_BRANCHES[$INDEX]
                        case '*'
                            if test (string match -r "[0-9]+" $CHECKOUT_INDEX)
                                set -l INDEX (math "$CHECKOUT_INDEX + 1")
                                if test $INDEX -gt (count $PR_TRAIN_BRANCHES)
                                    if not set -q _flag_silent
                                        echo (set_color red)"'"$CHECKOUT_INDEX"' exceeds the number of branches. Did you mean '"(math (count $PR_TRAIN_BRANCHES) - 1)"'?"
                                    end
                                    return 1
                                end
                                cb $PR_TRAIN_BRANCHES[$INDEX]
                            else
                                if not set -q _flag_silent
                                    echo (set_color red)"'"$CHECKOUT_INDEX"' is not a number. Exiting..."
                                end
                            end
                    end
                end
            case merge m
                pr-train --exists
                and begin
                    set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                    set -p PR_TRAIN_BRANCHES $MERGE_BRANCH
                    git fetch origin $MERGE_BRANCH
                    # Check if we are continuing a pr-train merge
                    if set -q _flag_continue
                        # Find the current index and merge from there
                        set PR_TRAIN_BRANCHES $PR_TRAIN_BRANCHES[(contains -i $CURRENT_BRANCH $PR_TRAIN_BRANCHES)..-1]
                        # Check if an existing merge is still in progress
                        if test -f "$(git rev-parse --show-toplevel)/.git/MERGE_HEAD"
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
                    else
                        # Set default start indexes
                        set -l START_INDEX 1
                        set -l END_INDEX -1
                        if set -q _flag_from
                            if not test _flag_from
                                if not set -q _flag_silent
                                    echo (set_color red)"Invalid value passed to parameter '--from'. Exiting..."
                                end
                                return 1
                            end
                            switch $_flag_from
                                case head # Skip green
                                    set START_INDEX 2
                                case here # Current branch
                                    set START_INDEX (contains -i $CURRENT_BRANCH $PR_TRAIN_BRANCHES)
                                case '*'
                                    if test (string match -r "[0-9]+" $_flag_from)
                                        set START_INDEX (math $_flag_from + 1)
                                    else
                                        if not set -q _flag_silent
                                            echo (set_color red)"'"$_flag_from"' is not a number. Exiting..."
                                        end
                                        return 1
                                    end
                            end
                        end
                        if set -q _flag_to
                            if not test _flag_to
                                if not set -q _flag_silent
                                    echo (set_color red)"Invalid value passed to parameter '--to'. Exiting..."
                                end
                                return 1
                            end
                            switch $_flag_to
                                case tail # Skip green
                                    set END_INDEX -1
                                case '*'
                                    if test (string match -r "[0-9]+" $_flag_to)
                                        # This index is 2 ahead since we ahve green at the start and the array starts at 1
                                        set END_INDEX (math $_flag_to + 2)
                                    else
                                        if not set -q _flag_silent
                                            echo (set_color red)"'"$_flag_to"' is not a number. Exiting..."
                                        end
                                        return 1
                                    end
                            end
                        end
                        set PR_TRAIN_BRANCHES $PR_TRAIN_BRANCHES[$START_INDEX..$END_INDEX]
                    end
                    if test (count $PR_TRAIN_BRANCHES) -gt 1
                        if not set -q _flag_silent
                            echo "Going to merge "(count $PR_TRAIN_BRANCHES)" branches:"
                        end
                    else
                        if not set -q _flag_silent
                            echo (set_color grey)"Already at tail. Exiting..."
                        end
                        return 0
                    end
                    if not set -q _flag_silent
                        echo (set_color green)(string join (set_color normal)' > '(set_color green) $PR_TRAIN_BRANCHES)
                    end
                    read -P (set_color red)"Press enter to continue ⏎"(set_color normal)
                    if test $status -gt 0
                        return $status
                    end
                    # Start merge loop
                    if set -q PR_TRAIN_BRANCHES
                        # Create sequence from 1 to the length of branches, loop through
                        for i in (seq (math (count $PR_TRAIN_BRANCHES) - 1))
                            if set -q _flag_ask_every_time
                                if not set -q _flag_silent
                                    echo "Going to checkout $PR_TRAIN_BRANCHES[$j]"
                                end
                                read -P (set_color red)"Press enter to continue ⏎"(set_color normal)
                                if test $status -gt 0
                                    return $status
                                end
                            end
                            # Set the current branch index to merge into
                            set -l j (math $i + 1)
                            # Checkout the head branch
                            if not set -q _flag_silent
                                echo "Checking out $PR_TRAIN_BRANCHES[$j]"
                            end
                            git checkout -q $PR_TRAIN_BRANCHES[$j]
                            # Merge the previous branch into current (default starts at green)
                            if not set -q _flag_silent
                                echo "Merging $PR_TRAIN_BRANCHES[$i] into $PR_TRAIN_BRANCHES[$j]"
                            end
                            git merge -q --no-edit $PR_TRAIN_BRANCHES[$i]
                            if test $status -gt 0
                                if not set -q _flag_silent
                                    echo (set_color red)"Conflicts during merge... Please resolve them and continue."
                                end
                                return $status
                            end
                            if not set -q _flag_silent
                                echo (set_color -i grey)"Pushing..."(set_color normal)
                            end
                            git push
                            if test $status -gt 0
                                if not set -q _flag_silent
                                    echo (set_color red)"Error during push..."
                                end
                                return $status
                            end
                        end
                        if not set -q _flag_silent
                            echo (set_color -i grey)"Done 🚉"
                        end
                    else
                        if not set -q _flag_silent
                            echo (set_color -i grey)"No branches found for '$PR_TRAIN_BRANCHES'. Exiting..."
                        end
                    end
                end
            case update-prs prs
                pr-train --exists
                and begin
                    # Get list from all the branches in the history
                    set -l PR_TRAIN_BRANCHES (string split " " (cat $PR_TRAIN_BRANCHES_FILE))
                    set -l ALL_PR_TRAIN_BRANCHES (string split " " (cat $ALL_PR_TRAIN_BRANCHES_FILE))
                    set -l PR_TRAIN_BRANCHES_MERGE $PR_TRAIN_BRANCHES
                    if set -q PR_TRAIN_BRANCHES
                        # Set default base to main branch
                        set -p PR_TRAIN_BRANCHES_MERGE $MAIN_BRANCH
                        set -l NEW_PR_CREATED false
                        for i in (seq (math (count $PR_TRAIN_BRANCHES_MERGE) - 1))
                            # Set the current branch index to merge into
                            set -l j (math $i + 1)
                            set -l BASE_BRANCH $PR_TRAIN_BRANCHES_MERGE[$i]
                            set -l BRANCH $PR_TRAIN_BRANCHES_MERGE[$j]
                            # Check if a branch already exists
                            if has-pr $BRANCH merged,open
                                if not set -q _flag_silent
                                    echo (set_color grey)"PR already exists for $BRANCH"(set_color normal)
                                end
                                if has-pr $BRANCH merged
                                    # Do something?
                                end
                                if has-pr $BRANCH open
                                    # Do something?
                                    # Ensure base branch is up to date
                                    gh pr edit $BRANCH --base $BASE_BRANCH
                                end
                            else
                                set NEW_PR_CREATED true
                                if not set -q _flag_silent
                                    echo "Creating PR for "(set_color green)$BRANCH(set_color normal)" with base "(set_color green)$BASE_BRANCH(set_color normal)"..."
                                end
                                gh pr create --draft --title (string replace -a "-" " " $BRANCH) --body "<pr-train></pr-train>" --base $BASE_BRANCH --head $BRANCH
                            end
                        end
                        if not set -q _flag_silent
                            echo (set_color grey)"Updating descriptions..."(set_color normal)
                        end
                        if test $NEW_PR_CREATED = true
                            # Delay list fetch so that newly created PR's appear
                            sleep 3
                        end
                        set -l TMP_DIR "$BASE_DIR/tmp/"
                        set -l PRS_INFO_DIR "$BASE_DIR/tmp/prs/"
                        mkdir $TMP_DIR
                        mkdir $PRS_INFO_DIR
                        # Loop through all the history of branches for the pr list
                        for PR_BRANCH in $ALL_PR_TRAIN_BRANCHES
                            set -l PR_INFO (gh pr view $PR_BRANCH --json number,title,body,url,headRefName)
                            set -l FILENAME $PRS_INFO_DIR(timestamp)"-"$PR_BRANCH".json"
                            echo $PR_INFO >$FILENAME
                            sleep 1
                        end

                        set -l PR_LIST_JSON (echo (jq -n '[inputs]' $PRS_INFO_DIR*.json))
                        for i in (seq 0 (math (echo $PR_LIST_JSON | jq '. | length') - 1))
                            set -l PR_NUMBER (echo $PR_LIST_JSON | jq -r .[$i].number)
                            set -l PR_BRANCH (echo $PR_LIST_JSON | jq -r .[$i].headRefName)
                            # Write old body to tmp file
                            echo -e (echo $PR_LIST_JSON | jq -r .[$i].body) >$TMP_DIR"old-body-"$PR_NUMBER".txt"
                            # Write pr-train table to tmp file
                            if set -q _flag_simple
                                echo -e (__pr-train-simple (echo $PR_LIST_JSON) $PR_BRANCH) >$TMP_DIR"table-"$PR_NUMBER".txt"
                            else
                                echo -e (__pr-train-table (echo $PR_LIST_JSON) $PR_BRANCH) >$TMP_DIR"table-"$PR_NUMBER".txt"
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
                        if not set -q _flag_silent
                            echo (set_color -i grey)"No branches found for '$PR_TRAIN_BRANCHES'. Exiting..."
                        end
                    end
                end
            case '*'
                if test -d $TYPE
                    if not set -q _flag_silent
                        echo (set_color red)"Unknown option: "(set_color grey)"<empty>"
                    end
                else
                    if not set -q _flag_silent
                        echo (set_color red)"Unknown option: $TYPE"
                    end
                end
        end
    end
end
