function clean-branches --description 'Cleans up old branches'
    has-repo
    and begin
        set -l BRANCHES (git branch -vv | grep ': gone]' | string match -r -a -g '\[origin\/(.*): gone\]')
        if test (count $BRANCHES) -lt 1
            echo (set_color grey)No branches found. Exiting...
            return
        end

        if test (count $BRANCHES) -gt 1
            echo Found (count $BRANCHES) branches:
        else
            echo Found (count $BRANCHES) branch:
        end
        set_color yellow
        for BRANCH in $BRANCHES
            echo $BRANCH
        end
        set_color normal

        read -P "Are you sure you want to delete them? ⏎"
        if test $status -gt 0
            return $status
        end
        for BRANCH in $BRANCHES
            echo "Deleting branch "(set_color red)$BRANCH(set_color normal)
            git branch -D $BRANCH
        end
    end
end
