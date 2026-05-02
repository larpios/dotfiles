use misc.nu is-exe

export def --wrapped --env main [...args] : {
  if not (is-exe tere) {
    error make '`tere` not found'
  }

  let result = ( ^tere ...$args )
  if $result != "" {
    cd $result
  }
}
