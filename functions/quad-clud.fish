function quad-clud --description "Launch clud with a persistent per-color Claude session"
    set -l color $argv[1]
    switch $color
        case red blue green yellow
        case '*'
            echo "quad-clud: unknown color '$color'" >&2
            return 1
    end
    # The SessionStart hook (quad-session-track.sh) sees QUAD_COLOR and writes the
    # live session id to the pointer file, so the pointer follows /clear and resume.
    set -lx QUAD_COLOR $color
    set -l pointer ~/.local/state/quad/$color
    if test -f $pointer
        set -l id (string trim <$pointer)
        # clud runs claude from ~/work, so its sessions live under this project dir
        if test -n "$id" -a -f ~/.claude/projects/-home-coder-work/$id.jsonl
            clud --resume $id
            return
        end
    end
    clud --name $color
end
