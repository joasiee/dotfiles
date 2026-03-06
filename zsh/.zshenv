# Ensure fzf binary installed via ~/.fzf is on PATH
if [ -d "$HOME/.fzf/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.fzf/bin:"*) ;;
    *) export PATH="$HOME/.fzf/bin:$PATH" ;;
  esac
fi
