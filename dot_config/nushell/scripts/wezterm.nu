use misc.nu is-exe

export def --wrapped imgview [...args] {
  verify-wezterm
  ^wezterm imgcat ...$args
}

def verify-wezterm [] {
  if not (is-exe wezterm) {
    error make "wezterm is not installed"
  }
}
