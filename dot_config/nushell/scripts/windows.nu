# Windows related commands.
# Don't use it on non-Windows systems, it uses powershell commands and doesn't check if you are on Windows

use std/log

export def --env "path append" [] {
  log debug $"path append {($in)}"
  $env.PATH | append $in | path set
}

export def --env "path prepend" [] {
  log debug $"path prepend {($in)}"
  $env.PATH | prepend $in | path set
}

export def "path set" [] : list<string> -> nothing { 
  { PATH: ($in | str join ';') } | env set
}

export def "path optimize" [] : [string -> string, list<string> -> list<string>] {
  const HOME = $nu.home-dir
  const LOCALAPPDATA = $"($HOME)\\AppData\\Local"
  const APPDATA = $"($HOME)\\AppData\\Roaming"
  const PROGRAMFILES = "C:\\Program Files"
  const PROGRAMDATA = "C:\\ProgramData"
  const USERPROFILE = $"($HOME)"

  $in 
  | str replace $LOCALAPPDATA '%localappdata%' 
  | str replace $APPDATA '%appdata%' 
  | str replace $PROGRAMFILES '%programfiles%' 
  | str replace $PROGRAMDATA '%programdata%' 
  | str replace $USERPROFILE '%userprofile%' 
}

# Set environment variable
export def "env set" [
  --scope (-s): string = "user", # Environment variable scope, `user` or `machine`
] : record<key: string, value: list<string>> -> nothing {
  let set_cmd = { |key, value|
    $"[System.Environment]::SetEnvironmentVariable\('($key)', '($in)', [System.EnvironmentVariableTarget]::($scope)\)"
  }

  $in 
  | items { |key, value| 
    if ($value | is-not-empty) {
      pwsh -c (^$set_cmd $key $value)
    } 
  }
}

# Get environment variable
export def "env get" [
  --scope (-s): string = "user", # Environment variable scope, `user` or `machine`
] : [string -> list<string>, list<string> -> record<key: string, value: list<string>>] {

  let get_cmd = { |key|
    $"[System.Environment]::GetEnvironmentVariable\('($key)', [System.EnvironmentVariableTarget]::($scope)\)"
  }

  if ($in | describe | str starts-with 'list') {
    if ($in | is-empty) {
      return []
    }

    $in 
    | reduce --fold {} {|key, acc|
      $acc | insert $key (pwsh -c (^$get_cmd $key) | split row ';')
    }
  } else {
    (pwsh -c (^$get_cmd $in) | split row ';')
  }
}

# Run a powershell command
#
# This wrapper is to prefer `pwsh.exe` if it is available, but to fall back to `powershell.exe` otherwise.
def --wrapped pwsh [...args] {
  let pwsh_cmd = if (is-exe pwsh.exe) { 'pwsh.exe' } else { 'powershell.exe' }
  ^$pwsh_cmd ...$args
}
