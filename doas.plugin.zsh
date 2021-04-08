# author: monesonn <git.io/monesonn>
# description: doas or doasedit before the command; triggered by double esc
# credit: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/doas/doas.plugin.zsh

__doas-replace-buffer() {
    local old=$1 new=$2 space=${2:+ }
    if [[ ${#LBUFFER} -le ${#old} ]]; then
        RBUFFER="${space}${BUFFER#$old }"
        LBUFFER="${new}"
    else
        LBUFFER="${new}${space}${LBUFFER#$old }"
    fi
}

doas-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    # Save beginning space
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} = " " ]]; then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi
    # Get the first part of the typed command and check if it's an alias to $EDITOR
    # If so, locally change $EDITOR to the alias so that it matches below
    if [[ -n "$EDITOR" ]]; then
        local cmd="${${(Az)BUFFER}[1]}"
        if [[ "${aliases[$cmd]} " = (\$EDITOR|$EDITOR)\ * ]]; then
            local EDITOR="$cmd"
        fi
    fi

    if [[ -n $EDITOR && $BUFFER = $EDITOR\ * ]]; then
        __doas-replace-buffer "$EDITOR" "doas $(alias $cmd | sed -r "s/.*='(.*)'/\1/;s/.*=(.*)/\1/")"
    elif [[ -n $EDITOR && $BUFFER = \$EDITOR\ * ]]; then
        __doas-replace-buffer "\$EDITOR" "doas $(alias $cmd | sed -r "s/.*='(.*)'/\1/;s/.*=(.*)/\1/")"
    elif [[ $BUFFER = "doas $EDITOR"\ * ]]; then
        __doas-replace-buffer "doas $(alias $cmd | sed -r "s/.*='(.*)'/\1/;s/.*=(.*)/\1/")" "$EDITOR"
    elif [[ $BUFFER = doas\ * ]]; then
        __doas-replace-buffer "doas" ""
    else
        LBUFFER="doas $LBUFFER"
    fi
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"
}

zle -N doas-command-line
# Defined shortcut keys: [Esc] [Esc]
bindkey -M emacs '\e\e' doas-command-line
bindkey -M vicmd '\e\e' doas-command-line
bindkey -M viins '\e\e' doas-command-line
