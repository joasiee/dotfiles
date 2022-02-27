if [ -f "$HOME/.ssh/id_ed25519" ]; then
  {eval $(keychain --eval --agents ssh id_ed25519)} > /dev/null 2>&1
fi

if [ -n "$PYTHONPATH" ]; then
    export PYTHONPATH='/home/joasiee/.local/lib/python3.10/site-packages/pdm/pep582':$PYTHONPATH
else
    export PYTHONPATH='/home/joasiee/.local/lib/python3.10/site-packages/pdm/pep582'
fi
