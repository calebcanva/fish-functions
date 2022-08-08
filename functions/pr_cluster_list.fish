function pr_cluster_list --argument pr_list_info current_branch
    set -a pr_cluster_list_string "<pr-cluster>"
    set -a pr_cluster_list_string "\n"
    set -a pr_cluster_list_string "\n### Other PRs in this ticket:"
    set -a pr_cluster_list_string "\n"
    for index in (seq (echo $pr_list_info | jq '. | length'))
        set -l i (math $index - 1)
        set -l pr_branch_name (echo $pr_list_info | jq -r .[$i].headRefName)
        set -l pr_number (echo $pr_list_info | jq -r .[$i].number)
        if test (string match $current_branch $pr_branch_name)
            set -a pr_cluster_list_string "\n"(printf -- "- #%s 👈" $pr_number)
        else
            set -a pr_cluster_list_string "\n"(printf -- "- #%s" $pr_number)
        end
    end
    set -a pr_cluster_list_string "\n"
    set -a pr_cluster_list_string "\n</pr-cluster>"
    echo $pr_cluster_list_string
end
