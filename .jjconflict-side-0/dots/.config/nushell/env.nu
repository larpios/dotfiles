use misc.nu is-exe
use std/util 'path add'
const AUTOLOAD_DIR = $nu.config-path | path dirname | path join "autoload"

if not ($AUTOLOAD_DIR | path exists) {
  mkdir $AUTOLOAD_DIR
}

const ENV_DIRS = [
  '/usr/bin',
  '/usr/local/bin',
  '/bin'
  '/nix/var/nix/profiles/default/bin',
  '/opt/homebrew/bin'
  '~/.nix-profile/bin',
  '~/.cargo/bin',
  '~/.local/bin',
  '~/.cache/.bun/bin',
  '~/.bun/bin',
]

for $dir in $ENV_DIRS {
  path add $dir
}

if (is-exe direnv) {
  $env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt?
    | default []
    | append {||
      ^direnv export json
      | from json --strict
      | default {}
      | items {|key, value|
        let value = do (
          {
            "PATH": {
              from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                           to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
            }
          }
          | merge ($env.ENV_CONVERSIONS? | default {})
          | get ([[value, optional, insensitive]; [$key, true, true] [from_string, true, false]] | into cell-path)
          | if ($in | is-empty) { {|x| $x} } else { $in }
        ) $value
        return [ $key $value ]
      }
      | into record
      | load-env
    }
  )
}

if (is-exe starship) {
    starship init nu | save -f ($AUTOLOAD_DIR | path join "starship.nu")
}
if (is-exe mise) {
    mise activate nu | save -f ($AUTOLOAD_DIR | path join "mise.nu")
}
if (is-exe zoxide) {
    zoxide init nushell | save -f ($AUTOLOAD_DIR | path join "zoxide.nu")
}
if (is-exe carapace) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
    carapace _carapace nushell | save -f ($AUTOLOAD_DIR | path join "carapace.nu")
}
if (is-exe atuin) {
  atuin init nu | save -f ($AUTOLOAD_DIR | path join "atuin.nu")
}
