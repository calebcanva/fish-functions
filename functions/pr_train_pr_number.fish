function pr_train_pr_number --argument branch
    echo (gh pr list --author "@me" --head $branch | grep -o "^[0-9]*")[1]
end
