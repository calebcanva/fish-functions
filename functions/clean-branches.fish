function clean-branches --description 'Cleans up old branches'
    begin
        set -l branches (git branch -vv | grep ': gone]' | string match -r -a -g '\[origin\/(.*): gone\]')
        if test (count $branches) -gt 1
            echo Found (count $branches) branches:
        else
            echo Found 1 branch: 
        end
        set_color yellow
        for branch in $branches
            echo $branch
        end
        set_color normal

        read -P "Are you sure you want to delete them? ⏎"
        if test $status -gt 0
            return $status
        end
        for branch in $branches
            echo "Deleting branch "(set_color red)$branch(set_color normal)
            git branch -D $branch
        end
    end
end