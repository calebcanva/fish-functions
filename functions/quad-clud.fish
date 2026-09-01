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
    # The quad-<color> themes (~/.claude/themes/) recolor Clawd via the undocumented clawd_body token.
    set -l theme '{"theme":"custom:quad-'$color'"}'
    set -l pointer ~/.local/state/quad/$color
    # clud runs claude from ~/work, so its sessions live under this project dir
    set -l projects ~/.claude/projects/-home-coder-work
    if test -f $pointer
        set -l id (string trim <$pointer)
        if test -n "$id" -a -f $projects/$id.jsonl
            clud --resume $id --settings $theme
            return
        end
    end
    # A dangling pointer means the session died before its transcript was flushed
    # (e.g. a force-killed pane). Fall back to the newest transcript whose
    # agent-name record matches this quadrant; copies of such records embedded
    # in tool output never match because their quotes are JSON-escaped.
    set -l fallback (grep -lsF '"agentName":"'$color'"' $projects/*.jsonl | xargs -r ls -1t | head -1)
    if test -n "$fallback"
        clud --resume (basename $fallback .jsonl) --settings $theme
        return
    end
    # A fresh session has no preloaded state, so set the session color at startup.
    # A resumed session preloads its color from the transcript. /clear still drops it.
    clud --name $color --settings $theme "/color $color"
end
