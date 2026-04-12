use misc.nu is-exe

export def --wrapped imgview [...args] {
  verify-wezterm
  
  for arg in $args {
    for img in (glob $arg) {
      ^wezterm imgcat $img
    }
  }
}

def verify-wezterm [] {
  if not (is-exe wezterm) {
    error make "wezterm is not installed"
  }
}
