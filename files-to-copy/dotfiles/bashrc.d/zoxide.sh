# zoxide (smart cd)
# Only run in interactive shells
case $- in
  *i*) ;;
  *) return ;;
esac

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
else
  echo "==> zoxide is not installed. Please install it!"
fi
