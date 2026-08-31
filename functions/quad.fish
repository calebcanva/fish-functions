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
        # Size the detached session explicitly so all four splits fit
        tmux new-session -d -s $session -x 220 -y 50 'fish -C clud'
        for i in (seq 3)
            tmux split-window -t $session: 'fish -C clud'
            tmux select-layout -t $session: tiled
        end
        # Tint each quadrant: red, blue, green, yellow (top-left, top-right, bottom-left, bottom-right)
        set -l tints '#3a2020' '#1f2a3f' '#1f3325' '#38321c'
        set -l idx 1
        for pane in (tmux list-panes -t $session: -F '#{pane_id}')
            tmux select-pane -t $pane -P "bg=$tints[$idx]"
            set idx (math $idx + 1)
        end
        tmux select-pane -t $session:0.0
    end

    tmux attach-session -t $session
end
