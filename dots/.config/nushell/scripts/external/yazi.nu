use std/log
use misc.nu is-exe

export def --env --wrapped y [...args] {
  if not (is-exe yazi) {
    error make '`yazi` not found'
  }

  let tmp = (mktemp -t "yazi-cwd.XXXXX")
  ^yazi ...$args --cwd-file $tmp

  let cwd = open $tmp
  if $cwd != "" and $cwd != $env.PWD {
    cd $cwd
  }

  rm -fp $tmp
}

export-env {
  $env.YAZI_CONFIG_HOME = ('~/.config/yazi' | path expand)
}
