function wkt-port
    set -l PORT 9090
    set -l WORKTREE (git rev-parse --show-toplevel)
    set -l NUM (string match -r "[0-9]" (string split "-" $WORKTREE)[-1] != "")
    switch $NUM
    case 2
        set -l PORT 9091
    case 3
        set -l PORT 9092
    case 4
        set -l PORT 9093
    case 5
        set -l PORT 9094
    case 6
        set -l PORT 9095
    case 7
        set -l PORT 9096
    case 8
        set -l PORT 9097
    case 9
        set -l PORT 9098
    case '*'
        set -l PORT 9090
    end
    return $PORT
end
