function pr-cluster-list --argument PR_LIST CURRENT_BRANCH
    set -a STR "<pr-cluster>"
    set -a STR "\n"
    set -a STR "\n### Other PRs in this ticket:"
    set -a STR "\n"
    for i in (seq 0 (math (echo $PR_LIST | jq '. | length')) - 1)
        set -l PR_BRANCH (echo $PR_LIST | jq -r .[$i].headRefName)
        set -l PR_NUMBER (echo $PR_LIST | jq -r .[$i].number)
        if test (string match $CURRENT_BRANCH $PR_BRANCH)
            set -a STR "\n"(printf -- "- #%s 👈" $PR_NUMBER)
        else
            set -a STR "\n"(printf -- "- #%s" $PR_NUMBER)
        end
    end
    set -a STR "\n"
    set -a STR "\n</pr-cluster>"
    echo $STR
end
