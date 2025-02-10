function nb --description 'Create a fresh branch off green'
    begin
        set -l BRANCH_NAME
        if set -q argv[1]
            set BRANCH_NAME (string join " " $argv)
        else
            # For some reason I have to put it in another variable otherwise `read` won't override :sadge:
            read -l -P 'Branch name: ' READ
            set BRANCH_NAME $READ
        end
        if test $status -gt 0; or not test $BRANCH_NAME
            echo Some details missing. Exiting...
            return $status
        end
        echo (set_color -i grey)Fetching green...(set_color normal)
        git fetch origin green
        set FULL_BRANCH_NAME (slugify "caleb-$BRANCH_NAME")
        echo Checking out new branch $FULL_BRANCH_NAME
        git checkout -b $FULL_BRANCH_NAME origin/green --no-track
    end
end
