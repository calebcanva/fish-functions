function nb --description 'Create a fresh branch off green'
    begin
        git fetch origin green
        read -l -P 'Jira ticket: ' JIRA_TICKET
        if test $status -gt 0
            return $status
        end
        read -l -P 'Branch name: ' BRANCH_NAME
        if test $status -gt 0
            return $status
        end
        if test $JIRA_TICKET
            and test $BRANCH_NAME
            set FULL_BRANCH_NAME (slugify (whoami)"-$JIRA_TICKET-$BRANCH_NAME")
            echo Checking out new branch $FULL_BRANCH_NAME
            git checkout -b $FULL_BRANCH_NAME origin/green --no-track
        else
            echo Some details missing. Exiting...
        end
    end
end
