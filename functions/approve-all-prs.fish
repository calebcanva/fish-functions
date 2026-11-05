function approve-all-prs --description 'Approve every open Canva PR that requests my review, with no review body'
    set -l dry_run 0
    if contains -- --dry-run $argv
        set dry_run 1
    end

    set -l repo Canva/canva
    set -l prs (gh -R $repo pr list --search "review-requested:@me -is:draft" --state open --limit 50 \
        --json number,title --jq '.[] | "\(.number)\t\(.title)"')

    if test (count $prs) -eq 0
        echo (set_color grey)"Nothing to approve."(set_color normal)
        return 0
    end

    set -l failed 0
    for line in $prs
        set -l n (string split -f1 \t -- $line)
        set -l title (string split -f2 \t -- $line)
        if test $dry_run -eq 1
            echo "would approve "(set_color yellow)"#$n"(set_color normal)"  $title"
            continue
        end
        if gh -R $repo pr review $n --approve
            echo "approved "(set_color green)"#$n"(set_color normal)"  $title"
        else
            echo "FAILED "(set_color red)"#$n"(set_color normal)"  $title" >&2
            set failed 1
        end
    end
    return $failed
end
