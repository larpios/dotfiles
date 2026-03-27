$env.config.completions.external.enable = true
$env.config.completions.external.max_results = 200
$env.config.edit_mode = 'vi'
$env.config.history.file_format = 'sqlite'
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

const CONFIG_DIR = $nu.config-path | path dirname
const THEMES_DIR = $CONFIG_DIR | path join "themes"
const MODULES_DIR = $CONFIG_DIR | path join "modules"
const AUTOLOAD_DIR = $CONFIG_DIR | path join "autoload"

const THEME = "catppuccin_mocha"
const THEME_FILE = $THEMES_DIR | path join $"($THEME).nu"
source-env $THEME_FILE

export-env {
    $env.GITHUB_USERNAME = 'larpios'
    $env.GITHUB_HTTP = $"https://github.com/($env.GITHUB_USERNAME)"
    $env.GITHUB_SSH = $"git@github.com:($env.GITHUB_USERNAME)"
    $env.XDG_CONFIG_HOME = ('~/.config' | path expand)
    $env.XDG_DATA_HOME = ('~/.local/share' | path expand)
    $env.XDG_CACHE_HOME = ('~/.cache' | path expand)
    $env.EDITOR = if (is-exe nvim) { 'nvim' } else { 'vim' }
    $env.XDG_CONFIG_HOME = ('~/.config' | path expand)
    $env.XDG_DATA_HOME = ('~/.local/share' | path expand)
    $env.XDG_CACHE_HOME = ('~/.cache' | path expand)
    $env.EDITOR = if (is-exe nvim) { 'nvim' } else { 'vim' }
    $env.VISUAL = $env.EDITOR
    $env.VISUAL = $env.EDITOR
}

use aliases.nu *
use list.nu *
use windows.nu
use misc.nu *
use symlink.nu *
use wezterm.nu *

use external/yazi.nu *
use external/tere.nu *
