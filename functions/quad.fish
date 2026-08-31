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
        tmux select-pane -t $session:0.0
    end

    tmux attach-session -t $session
end
