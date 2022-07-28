function pr_train_table --argument pr_list_info current_branch
    set -a pr_train_table_string "<pr-train>"
    set -a pr_train_table_string "\n"
    set -a pr_train_table_string "\n### PR Train 🚂"
    set -a pr_train_table_string "\n"
    set -a pr_train_table_string "\n| PR | Description |   |"
    set -a pr_train_table_string "\n| -- | ------ | - |"
    for index in (seq (echo $pr_list_info | jq '. | length'))
        set -l i (math $index - 1)
        set -l pr_branch_name (echo $pr_list_info | jq -r .[$i].headRefName)
        set -l pr_title (string replace -r -i '\[[A-Z]+(-[0-9]*)*\]' '' (echo $pr_list_info | jq -r .[$i].title))
        set -l pr_url (echo $pr_list_info | jq -r .[$i].url)
        set -l pr_number (echo $pr_list_info | jq -r .[$i].number)
        if test (string match $current_branch $pr_branch_name)
            set -a pr_train_table_string "\n"(printf "| #%s | [%s](%s) | %s |" $pr_number $pr_title $pr_url "👈")
        else
            set -a pr_train_table_string "\n"(printf "| #%s | [%s](%s) |    |" $pr_number $pr_title $pr_url)
        end
    end
    set -a pr_train_table_string "\n"
    set -a pr_train_table_string "\n</pr-train>"
    echo $pr_train_table_string
end
