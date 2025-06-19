#!/bin/bash

# This script is called by the OS daemon with one argument: "dark" or "light"
MODE=$1

# --- Define Absolute Paths ---
LN_CMD="/bin/ln"
NVR_CMD="/opt/homebrew/bin/nvr"
TMUX_CMD="/opt/homebrew/bin/tmux"
XARGS_CMD="/usr/bin/xargs"
AWK_CMD="/usr/bin/awk"
GREP_CMD="/usr/bin/grep"

# --- Main Logic ---

THEME_DIR="$HOME/.tmux/config"

# 1. Update Tmux theme
if [ "$MODE" = "light" ]; then
  "$LN_CMD" -sf "$THEME_DIR/theme-light.conf" "$THEME_DIR/theme.conf"
else
  "$LN_CMD" -sf "$THEME_DIR/theme-dark.conf" "$THEME_DIR/theme.conf"
fi

# 2. Update Neovim instances
# Clean the server list to get one path per line.
NVIM_SERVERS=$("$NVR_CMD" --serverlist | "$GREP_CMD" -v 'fzf-lua' | "$AWK_CMD" '{for(i=1;i<=NF;i++)print $i}')

# If the cleaned list is not empty, update each server.
if [ -n "$NVIM_SERVERS" ]; then
  # The --nostart flag is the key. It tells nvr to fail silently
  # if a socket is stale, instead of opening a new nvim instance.
  echo "$NVIM_SERVERS" | "$XARGS_CMD" -I {} "$NVR_CMD" --servername "{}" --nostart -c "set background=$MODE"
fi

# 3. Trigger the tmux hook to reload its theme
"$TMUX_CMD" source-file "$THEME_DIR/theme.conf"
