function pr_train_table_simple --argument pr_list_info current_branch
    set -a pr_train_table_string "<pr-train>"
    set -a pr_train_table_string "\n"
    set -a pr_train_table_string "\n### PRs"
    set -a pr_train_table_string "\n"
    for index in (seq (echo $pr_list_info | jq '. | length'))
        set -l i (math $index - 1)
        set -l pr_branch_name (echo $pr_list_info | jq -r .[$i].headRefName)
        set -l pr_number (echo $pr_list_info | jq -r .[$i].number)
        if test (string match $current_branch $pr_branch_name)
            set -a pr_train_table_string "\n"(printf "\- #%s 👈" $pr_number)
        else
            set -a pr_train_table_string "\n"(printf "\- #%s" $pr_number)
        end
    end
    set -a pr_train_table_string "\n"
    set -a pr_train_table_string "\n</pr-train>"
    echo $pr_train_table_string
end
