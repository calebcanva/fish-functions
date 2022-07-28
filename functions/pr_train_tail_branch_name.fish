function pr_train_tail_branch_name
    set -l pr_train_branches (git_branches | grep (pr_train_head_branch_name))
    echo $pr_train_branches[-1]
end
