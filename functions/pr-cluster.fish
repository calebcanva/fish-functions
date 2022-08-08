function pr-cluster
    begin
        read -l -P 'Jira ticket: ' jira_ticket
        if test $status -gt 0
            return $status
        end
        # Get new PR list again
        set -l pr_jira_ticket (slugify $jira_ticket)
        set -l pr_list_json_open (gh pr list --state open --author "@me" --search $pr_jira_ticket --json number --json title --json body --json url --json headRefName)
        set -l pr_list_json_merged (gh pr list --state merged --author "@me" --search $pr_jira_ticket --json number --json title --json body --json url --json headRefName)
        # Join the two arrays since gh doesn't support multiple statuses in a single request
        set -l pr_list_json (jq -n "$pr_list_json_open + $pr_list_json_merged")
        set -l pr_list_sorted (echo $pr_list_json | jq 'sort_by(.headRefName) | .')
        set -l tmp './.pr-cluster-tmp/'
        mkdir $tmp
        for i in (seq 0 (math (echo $pr_list_sorted | jq '. | length') - 1))
            set -l pr_cluster_current_branch (echo $pr_list_sorted | jq -r .[$i].headRefName)
            set -l pr_number (echo $pr_list_sorted | jq -r .[$i].number)
            echo "Updating PR: "$pr_number
            # Write old body to tmp file
            echo -e (echo $pr_list_sorted | jq -r .[$i].body) | tr '\r' '\n' > $tmp"old-body-"$pr_number".txt"
            # Write pr-train table to tmp file
            echo -e (pr_cluster_list (echo $pr_list_sorted) $pr_cluster_current_branch) > $tmp"cluster-"$pr_number".txt"
            # Write new body to tmp file
            if test (string match -r "<pr-cluster>.*</pr-cluster>" (cat $tmp"old-body-"$pr_number".txt" | tr '\n' '\b'))
                string replace -r "<pr-cluster>.*</pr-cluster>" (cat $tmp"cluster-"$pr_number".txt" | tr '\n' '\b') (cat $tmp"old-body-"$pr_number".txt" | tr '\n' '\b') | tr '\b' '\n' > $tmp"new-body-"$pr_number".txt"
            else
                cat $tmp"old-body-"$pr_number".txt" > $tmp"new-body-"$pr_number".txt"
                cat $tmp"cluster-"$pr_number".txt" >> $tmp"new-body-"$pr_number".txt"
            end
            # Edit PR with new body 
            gh pr edit $pr_number -F $tmp"new-body-"$pr_number".txt"
        end
        # Clean up tmp files
        rm -rf $tmp
    end
end
