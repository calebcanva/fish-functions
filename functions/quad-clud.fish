function quad-clud --description "Launch clud with a persistent per-color Claude session"
    set -l color $argv[1]
    # Fixed session UUIDs so each quadrant resumes the same conversation across devbox restarts
    set -l uuid
    switch $color
        case red
            set uuid 71a66e6c-3c06-4b4e-8a6f-cec04ea4d2d0
        case blue
            set uuid a8bae770-3d6f-457c-8a81-ae40ed9af1b7
        case green
            set uuid 6d7839e6-903b-45d1-984d-1dcbb0e31791
        case yellow
            set uuid 925454d9-9c27-4677-940d-17ab6a1a869c
        case '*'
            echo "quad-clud: unknown color '$color'" >&2
            return 1
    end
    # clud runs claude from ~/work, so its sessions live under this project dir
    if test -f ~/.claude/projects/-home-coder-work/$uuid.jsonl
        clud --resume $uuid
    else
        clud --session-id $uuid --name $color
    end
end
