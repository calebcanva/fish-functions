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
