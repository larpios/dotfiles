use misc.nu is-exe

export def --wrapped imgview [...args] {
  verify-wezterm
  
  for arg in $args {
    for img in (glob $arg) {
      let result = ^wezterm imgcat $img | complete
      if $result.exit_code != 0 {
        error make {
          msg: $'Failed to show image `($img)`.'
          labels: [
            {
              text: 'Could NOT read this',
              span: (metadata $img).span
            }
          ]
        }
      }

      print $result.stdout
    }
  }
}

def verify-wezterm [] {
  if not (is-exe wezterm) {
    error make "wezterm is not installed"
  }
}
