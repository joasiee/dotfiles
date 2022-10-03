if [ -f "$HOME/.ssh/id_ed25519" ]; then
  {(eval "$(ssh-agent -s)")} > /dev/null 2>&1
  {(ssh-add ~/.ssh/id_ed25519)} > /dev/null 2>&1
fi

export OMP_NUM_THREADS=
export CMAKE_BUILD_PARALLEL_LEVEL=
