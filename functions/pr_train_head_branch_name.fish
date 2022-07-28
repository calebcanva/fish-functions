function pr_train_head_branch_name
    set -l current_branch (git branch --show-current)
    set -l current_branch_parts (string split - $current_branch)
    set -l base_branch ""
    if test (string match -r "[0-9]+" $current_branch_parts[-1])
        set base_branch (string join - $current_branch_parts[1..-2])
    else
        set base_branch (string join - $current_branch_parts)
    end
    echo $base_branch
end
