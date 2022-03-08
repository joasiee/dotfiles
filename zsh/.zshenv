if [ -f "$HOME/.ssh/id_ed25519" ]; then
  {eval $(keychain --eval --agents ssh id_ed25519)} > /dev/null 2>&1
fi
