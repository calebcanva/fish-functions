function pr_train_next_branch_name
    set -l pr_train_branches (git_branches | grep (pr_train_head_branch_name))
    set -l current_branch_parts (string split - $pr_train_branches[-1])
    if test (string match -r "[0-9]+" $current_branch_parts[-1])
        set next_branch (string join - $current_branch_parts[1..-2])"-"(math $current_branch_parts[-1] + 1)
    else
        set next_branch (string join - $current_branch_parts)"-1"
    end
    echo $next_branch
end
