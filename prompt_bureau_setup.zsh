prompt_bureau_setup () {
    autoload -U colors && colors
    prompt_bureau_user_color=${1:-'white'}
    prompt_bureau_path_color=${2:-$prompt_bureau_user_color}
    prompt_bureau_vcs_color=${3:-$prompt_bureau_user_color}

    autoload -Uz vcs_info add-zsh-hook
    prompt_bureau_vcs_style
    add-zsh-hook precmd prompt_bureau_precmd
    add-zsh-hook zshexit prompt_bureau_exit

    PROMPT=$(prompt_bureau_prompt)
}

prompt_bureau_prompt () {
    local color=green
    if [ "$UID" = "0" ]; then color=red; fi
    echo "> %{$fg[${color}]%}%(!.#.$)%{$reset_color%} "
}

prompt_bureau_string_width () {
    local str=$1
    echo ${#${(S%%)str//(\%([KF1]|)\{*\}|\%[Bbkf])}}
}

prompt_bureau_rprompt_file() {
    echo "/tmp/$(whoami)_zsh_rprompt.$$"
}

BUREAU_ASYNC_PROC=0

prompt_bureau_precmd () {
    # user@host path
    local left="%{$fg_bold[$prompt_bureau_user_color]%}%n%{$reset_color%}@%m %{$fg_bold[$prompt_bureau_path_color]%}%~%{$reset_color%} $(prompt_bureau_nvm)"
    # current time
    local right="[%*]"
    local offset=$(( $COLUMNS - $(prompt_bureau_string_width $left) - $(prompt_bureau_string_width $right) + 2 ))

    print -P "\n${left}" "${(l:$offset:: :)right}"

    # kill child if necessary
    if [[ "${BUREAU_ASYNC_PROC}" != 0 ]]; then
        kill -s HUP $BUREAU_ASYNC_PROC >/dev/null 2>&1 || :
    fi

    # start background computation
    prompt_bureau_vcs_prompt &!
    BUREAU_ASYNC_PROC=$!
}

prompt_bureau_vcs_style () {
    zstyle ':vcs_info:*' enable git
    # Check for staged and unstaged
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' max-exports 2
    local git_base="%{$fg[green]%}±%{$fg_bold[$prompt_bureau_vcs_color]%}%b %u%c%"
    zstyle ':vcs_info:git*' stagedstr "%{$fg_bold[green]%}●"
    zstyle ':vcs_info:git*' unstagedstr "%{$fg_bold[red]%}●"
    zstyle ':vcs_info:git*' formats "[${git_base}%{$reset_color%}]"
    zstyle ':vcs_info:git*' actionformats "[${git_base} %{$fg[magenta]%}⌘ %a%{$reset_color%}]"
}

prompt_bureau_nvm () {
    which nvm &>/dev/null || return
    echo "%B⬡%b ${$(nvm current)#v}"
}

prompt_bureau_vcs_prompt () {
    vcs_info
    printf "%s" "$vcs_info_msg_0_" > "$(prompt_bureau_rprompt_file)"

    # signal parent
    kill -s USR1 $$
}

prompt_bureau_exit () {
    rm -f "$(prompt_bureau_rprompt_file)" 2> /dev/null
}

TRAPUSR1 () {
    # read from temp file
    RPROMPT="$(cat $(prompt_bureau_rprompt_file))"

    # reset proc number
    BUREAU_ASYNC_PROC=0

    # redisplay
    zle && zle reset-prompt
}

prompt_bureau_setup $@
