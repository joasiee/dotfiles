# Tmux quick start

Start: `tmux new-session -A -s main` (creates main or reconnects to it).
Open a fresh Konsole window to load the Tmux Friendly profile first.

- Ctrl+Alt+-: split side by side (vertical divider).
- Ctrl+Alt++: split top/bottom (horizontal divider). Ctrl+Alt+= also works.
- New panes and windows start in the active pane's current folder.
- Alt+arrow: focus another pane. You can also click a pane.
- Drag pane borders to resize; mouse wheel scrolls history.
- Hold Shift while selecting with the mouse for Konsole selection;
  Ctrl+Shift+C copies and Ctrl+Shift+V pastes.
- Type `exit` to close the current shell/pane.

For these controls press Ctrl+B, release both keys, then press:

- `-` / `+`: split side by side / top and bottom (works in other terminals).
- `c`: create a window (tab).
- `n` / `p`: next / previous window.
- `z`: zoom current pane, then again to restore.
- `d`: detach; programs keep running. Reconnect with the start command above.
- `?`: show shortcuts; `q` exits help.
- `r`: reload ~/.tmux.conf.

The Ctrl+Alt split shortcuts are configured for Konsole while tmux's
alternate screen is active. The Konsole profile keeps the normal shell
startup; it does not automatically launch tmux.
