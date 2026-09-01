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
    # "/color <c>" as the launch prompt runs the slash command at startup; no settings key exists for session color.
    # The quad-<color> themes (~/.claude/themes/) recolor Clawd via the undocumented clawd_body token.
    set -l theme '{"theme":"custom:quad-'$color'"}'
    set -l pointer ~/.local/state/quad/$color
    if test -f $pointer
        set -l id (string trim <$pointer)
        # clud runs claude from ~/work, so its sessions live under this project dir
        if test -n "$id" -a -f ~/.claude/projects/-home-coder-work/$id.jsonl
            clud --resume $id --settings $theme "/color $color"
            return
        end
    end
    clud --name $color --settings $theme "/color $color"
end
