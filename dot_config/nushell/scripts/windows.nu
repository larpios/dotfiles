# Windows related commands
# Don't use it on non-Windows systems, it uses powershell commands and doesn't check if you are on Windows

use std/log

export def --env "path append" [] : [string -> nothing, list<string> -> nothing] {
  log debug $"path append {($in)}"
  $env.PATH | append $in | path set
}

export def --env "path prepend" [] : [string -> nothing, list<string> -> nothing] {
  log debug $"path prepend {($in)}"
  $env.PATH | prepend $in | path set 
}

export def "path set" [] : [list<string> -> nothing] {
  use misc.nu is-exe

  let new_path = $in | str join ';'
  
  let pwsh_cmd = if (is-exe pwsh.exe) { 'pwsh.exe' } else { 'powershell.exe' }
  let set_cmd = $"[System.Environment]::SetEnvironmentVariable\('PATH', '($new_path)', [System.EnvironmentVariableTarget]::User\)"

  log debug $"set path {($new_path)} using {($pwsh_cmd)}"
  ^$pwsh_cmd -c $set_cmd
}

export def "path optimize" [] : [list<string> -> list<string>, string -> string] {
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
