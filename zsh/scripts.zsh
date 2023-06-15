function gitadhd() {
    if [ $# -eq 2 ]; then
        if git --git-dir=$1 --work-tree=$2 diff --cached --quiet; then
            echo "No staged changes to commit"
            exit 1
        fi
    fi

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not in a git reopsitory"
        exit 1
    fi

    if git diff --cached --quiet >/dev/null 2>&1; then
        echo "No staged changes to commit"
        exit 1
    fi

    SESSION="Git-ADHD"
    SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

    if [ "$SESSIONEXISTS" = "" ]; then
        tmux new-session -d -s $SESSION

        tmux send-keys -t 0 "git diff --cached | delta" C-m
        tmux split-window -h
        tmux select-pane -t 1
        tmux send-keys -t 1 "git commit && tmux kill-session -t Git-ADHD" C-m

    fi

    tmux attach-session -t $SESSION:0

}
