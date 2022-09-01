function pr-train-table --argument PR_LIST_JSON --argument CURRENT_BRANCH
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
