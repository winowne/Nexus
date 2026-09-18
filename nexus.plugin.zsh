#path to the log file
mkdir -p "${HOME}/Nexus"
typeset -g ZSH_JSONL_LOG_FILE="${HOME}/Nexus/user_history.jsonl"

#function called before the execution of each command
_jsonl_log_preexec() {
    if ! command -v jq &>/dev/null; then
        return
    fi
    local cmd="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local pwd_dir="$PWD"
    local user_name="$USER"
    local host_name="$HOST"
    local shell_pid="$$"

    #safely constructing a jsonl string using jq
    local json_entry
    json_entry=$(jq -c -n \
        --arg ts "$timestamp" \
        --arg cmd "$cmd" \
        --arg pwd "$pwd_dir" \
        --arg user "$user_name" \
        --arg host "$host_name" \
         --argjson pid "$shell_pid" \
         '{timestamp: $ts, command: $cmd, pwd: $pwd, user: $user, host: $host, pid: $pid}')

    #write the generated string to a file
    echo "$json_entry" >> "$ZSH_JSONL_LOG_FILE"
}

#securely connecting to zsh
autoload -Uz add-zsh-hook
add-zsh-hook preexec _jsonl_log_preexec
