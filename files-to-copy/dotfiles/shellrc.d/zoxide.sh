# zoxide (smart cd)
# Works in both bash and zsh

# Only run in interactive shells
case $- in *i*) ;; *) return ;; esac

if command -v zoxide >/dev/null 2>&1; then
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval "$(zoxide init --cmd cd zsh)"
  else
    eval "$(zoxide init --cmd cd bash)"
  fi
else
  echo "==> zoxide is not installed. Please install it!"
fi
