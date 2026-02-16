# kitty shell integration
# Only run in interactive shells
case $- in
  *i*) ;;
  *) return ;;
esac

# Enable kitty shell integration if running in kitty terminal
if [ -n "$KITTY_INSTALLATION_DIR" ]; then
  if [ -f "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash" ]; then
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
  fi
fi
