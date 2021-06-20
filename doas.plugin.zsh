#      __                       __
#  ___/ /__  ___ ____  ___ ___ / /
# / _  / _ \/ _ `(_-<_/_ /(_-</ _ \
# \_,_/\___/\_,_/___(_)__/___/_//_/

# Author: monesonn <git.io/monesonn>
# Description: doas before the command; triggered by double esc.
# Credit: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/sudo/sudo.plugin.zsh

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
    # save beginning space
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} = " " ]]; then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi
    # get the first part of the typed command and check if it's an alias to $EDITOR
    # if so, locally change $EDITOR to the alias so that it matches below
    if [[ -n "$EDITOR" ]]; then
        local cmd="${${(Az)BUFFER}[1]}"
        if [[ "${aliases[$cmd]} " = (\$EDITOR|$EDITOR)\ * ]]; then
            local EDITOR="$cmd"
        fi
    fi
    # replace buffer conditions;
    # main roots:
    # - doasedit, whatever implementation (there's no official one and most likely will not);
    #             I use my own: http://git.io/doasedit
    # - doas before associated command to a given alias
    if [[ $(command -v doasedit) ]]; then
      if [[ -n $EDITOR && $BUFFER = $EDITOR\ * ]]; then
        __doas-replace-buffer "$EDITOR" "doasedit"
      elif [[ -n $EDITOR && $BUFFER = \$EDITOR\ * ]]; then
        __doas-replace-buffer "\$EDITOR" "doasedit"
      elif [[ $BUFFER = doasedit\ * ]]; then
        __doas-replace-buffer "doasedit" "$EDITOR"
      elif [[ $BUFFER = doas\ * ]]; then
        __doas-replace-buffer "doas" ""
      else
        LBUFFER="doas $LBUFFER"
      fi
    else
      [[ -n $(alias "$cmd") ]] && {
        LBUFFER=${$(alias $cmd)##*=};
        LBUFFER=${LBUFFER%\'};
        LBUFFER=${LBUFFER#\'};
      }
      if [[ $BUFFER = doas\ * ]]; then
        __doas-replace-buffer "doas" ""
      else
        LBUFFER="doas $LBUFFER"
      fi
    fi
    # preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"
}

zle -N doas-command-line

# defined shortcut keys: [esc] [esc]
bindkey -M emacs '\e\e' doas-command-line
bindkey -M vicmd '\e\e' doas-command-line
bindkey -M viins '\e\e' doas-command-line

