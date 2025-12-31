# zoxide (smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd bash)"
else
  echo "==> zoxide is not installed. Please install it!"
fi
