# Ensure Starship reads the repo config
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Ensure fzf binary installed by ~/.fzf is on PATH
if [ -d "$HOME/.fzf/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.fzf/bin:"*) ;;
    *) export PATH="$HOME/.fzf/bin:$PATH" ;;
  esac
fi
