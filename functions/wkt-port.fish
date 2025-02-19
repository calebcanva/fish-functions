function wkt-port
    set -l WORKTREE (git rev-parse --show-toplevel)
    set -l NUM (string match -r "[0-9]" (string split "-" $WORKTREE)[-1] != "")
    switch $NUM
    case 2
        set -g PORT 9091
    case 3
        set -g PORT 9092
    case 4
        set -g PORT 9093
    case 5
        set -g PORT 9094
    case 6
        set -g PORT 9095
    case 7
        set -g PORT 9096
    case 8
        set -g PORT 9097
    case 9
        set -g PORT 9098
    case '*'
        set -g PORT 9090
    end
    echo $PORT
end
