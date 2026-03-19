const AUTOLOAD_DIR: path = $nu.config-path | path dirname | path join "autoload"

# Creates *.nu files

if not ($AUTOLOAD_DIR | path exists) {
  mkdir $AUTOLOAD_DIR
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

if (is-exe yazi) {
  source yazi.nu
}
