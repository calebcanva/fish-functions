function __pr-cluster-list --argument PR_LIST CURRENT_BRANCH
    set -a STR "<pr-cluster>"
    set -a STR "\n"
    set -a STR "\n### Related PR's:"
    set -a STR "\n"
    for i in (seq 0 (math (echo $PR_LIST | jq '. | length') - 1))
        set -l PR_BRANCH (echo $PR_LIST | jq -r .[$i].headRefName)
        set -l PR_NUMBER (echo $PR_LIST | jq -r .[$i].number)
        if test (string match $CURRENT_BRANCH $PR_BRANCH)
            set -a STR "\n"(printf "- #%s 👈" $PR_NUMBER)
        else
            set -a STR "\n"(printf "- #%s" $PR_NUMBER)
        end
    end
    set -a STR "\n"
    set -a STR "\n</pr-cluster>"
    echo $STR
end

function pr-cluster
    begin
        read -l -P 'Jira ticket: ' JIRA_TICKET
        if test $status -gt 0
            return $status
        end
        # Get new PR list again
        set -l JIRA_TICKET (slugify $JIRA_TICKET)
        set -l PR_LIST_OPEN (gh pr list --state open --author "@me" --search $JIRA_TICKET --json number,title,body,url,headRefName)
        set -l PR_LIST_CLOSED (gh pr list --state merged --author "@me" --search $JIRA_TICKET --json number,title,body,url,headRefName)
        # Join the two arrays since gh doesn't support multiple statuses in a single request
        set -l PR_LIST_JSON (jq -n "$PR_LIST_OPEN + $PR_LIST_CLOSED")
        set -l PR_LIST_SORTED (echo $PR_LIST_JSON | jq 'sort_by(.headRefName) | .')
        set -l TMP './.pr-cluster-tmp/'
        mkdir $TMP
        for i in (seq 0 (math (echo $PR_LIST_SORTED | jq '. | length') - 1))
            set -l CURRENT_BRANCH (echo $PR_LIST_SORTED | jq -r .[$i].headRefName)
            set -l PR_NUMBER (echo $PR_LIST_SORTED | jq -r .[$i].number)
            echo "Updating PR: "$PR_NUMBER
            # Write old body to tmp file
            echo -e (echo $PR_LIST_SORTED | jq -r .[$i].body) | tr '\r' '\n' >$TMP"old-body-"$PR_NUMBER".txt"
            # Write pr-train table to tmp file
            echo -e (__pr-cluster-list (echo $PR_LIST_SORTED) $CURRENT_BRANCH) >$TMP"cluster-"$PR_NUMBER".txt"
            # Write new body to tmp file
            if test (string match -r "<pr-cluster>.*</pr-cluster>" (cat $TMP"old-body-"$PR_NUMBER".txt" | tr '\n' '\b'))
                string replace -r "<pr-cluster>.*</pr-cluster>" (cat $TMP"cluster-"$PR_NUMBER".txt" | tr '\n' '\b') (cat $TMP"old-body-"$PR_NUMBER".txt" | tr '\n' '\b') | tr '\b' '\n' >$TMP"new-body-"$PR_NUMBER".txt"
            else
                cat $TMP"old-body-"$PR_NUMBER".txt" >$TMP"new-body-"$PR_NUMBER".txt"
                cat $TMP"cluster-"$PR_NUMBER".txt" >>$TMP"new-body-"$PR_NUMBER".txt"
            end
            # Edit PR with new body 
            gh pr edit $PR_NUMBER -F $TMP"new-body-"$PR_NUMBER".txt"
        end
        # Clean up tmp files
        rm -rf $TMP
    end
end
