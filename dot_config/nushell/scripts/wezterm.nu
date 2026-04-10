use misc.nu is-exe

export def --wrapped imgview [...args] {
  verify-wezterm
  
  for arg in $args {
    ^wezterm imgcat $arg
  }
}

def verify-wezterm [] {
  if not (is-exe wezterm) {
    error make "wezterm is not installed"
  }
}
