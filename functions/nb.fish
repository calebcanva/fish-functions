function nb --description 'Create a fresh branch off green'
    begin
        git fetch origin green
        read -l -P 'Jira ticket: ' nb_jira_ticket
        read -l -P 'Branch name: ' nb_branch_name
        if test $nb_jira_ticket
            and test $nb_branch_name
            set nb_full_branch_name (slugify (whoami))-(slugify $nb_jira_ticket)-(slugify $nb_branch_name)
            echo Checking out new branch $nb_full_branch_name
            git checkout -b $nb_full_branch_name origin/green --no-track
        else
            echo Some details missing. Exiting...
        end
    end
end
