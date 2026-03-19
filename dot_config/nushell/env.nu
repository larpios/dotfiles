# env.nu
#
# Installed by:
# version = "0.106.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

def is_exec [cmd: string] {
  which $cmd | is-not-empty
}

let autoload_dir = $nu.user-autoload-dirs | first

if not ($autoload_dir | path exists) {
  mkdir $autoload_dir
}

if (is_exec starship) {
  starship init nu | save -f ($autoload_dir | path join "starship.nu")
}

if (is_exec mise) {
  mise activate nu | save -f ($autoload_dir | path join "mise.nu")
}

if (is_exec zoxide) {
  zoxide init nushell | save -f ($autoload_dir | path join "zoxide.nu")
}

http get --raw https://raw.githubusercontent.com/catppuccin/nushell/815dfc6ea61f2746ff27b54ef425cfeb7b51dda8/themes/catppuccin_mocha.nu | save -f ~/.config/nushell/themes/catppuccin_mocha.nu
