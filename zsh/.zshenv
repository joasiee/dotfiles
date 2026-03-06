# Ensure fzf binary installed via ~/.fzf is on PATH
if [ -d "$HOME/.fzf/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.fzf/bin:"*) ;;
    *) export PATH="$HOME/.fzf/bin:$PATH" ;;
  esac
fi

# Ensure ~/.local/bin (e.g. zoxide) is on PATH
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi
