function quad --description "Attach to the quad tmux session; create its 2x2 clud grid if needed"
    set -l session quad

    if not command -q tmux
        echo "quad: tmux is not installed" >&2
        return 1
    end

    if set -q TMUX
        echo "quad: already inside tmux" >&2
        return 1
    end

    if not tmux has-session -t $session 2>/dev/null
        set -l colors red blue green yellow
        # Size the detached session explicitly so all four splits fit
        tmux new-session -d -s $session -x 220 -y 50 "fish -C 'quad-clud $colors[1]'"
        for i in 2 3 4
            tmux split-window -t $session: "fish -C 'quad-clud $colors[$i]'"
            tmux select-layout -t $session: tiled
        end
        # Tint each quadrant: red, blue, green, yellow (top-left, top-right, bottom-left, bottom-right).
        # Tints are the Claude Code session colors (#e8555a #7cb0db #00b256 #dfad00)
        # blended 18% onto #121212; keep in sync with clawd_body in ~/.claude/themes/quad-*.json.
        set -l tints '#391e1f' '#252e36' '#0f2f1e' '#372e0f'
        set -l idx 1
        for pane in (tmux list-panes -t $session: -F '#{pane_id}')
            tmux select-pane -t $pane -P "bg=$tints[$idx]"
            set idx (math $idx + 1)
        end
        # Active pane border takes its quadrant's color (matched on the pane's
        # start command, which survives respawn and renumbering); white otherwise
        tmux set -w -t $session: pane-active-border-style '#{?#{m:*quad-clud red*,#{pane_start_command}},fg=#e8555a,#{?#{m:*quad-clud blue*,#{pane_start_command}},fg=#7cb0db,#{?#{m:*quad-clud green*,#{pane_start_command}},fg=#00b256,#{?#{m:*quad-clud yellow*,#{pane_start_command}},fg=#dfad00,fg=white}}}}'
        tmux select-pane -t $session:0.0
    end

    tmux attach-session -t $session
end
