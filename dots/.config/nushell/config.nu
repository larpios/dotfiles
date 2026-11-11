const CONFIG_DIR = $nu.config-path | path dirname
const THEMES_DIR = $CONFIG_DIR | path join "themes"
const MODULES_DIR = $CONFIG_DIR | path join "modules"
const AUTOLOAD_DIR = $CONFIG_DIR | path join "autoload"

const THEME = "catppuccin_mocha"
const THEME_FILE = $THEMES_DIR | path join $"($THEME).nu"

source-env $THEME_FILE

export-env {
    $env.XDG_CONFIG_HOME = ('~/.config' | path expand)
    $env.XDG_DATA_HOME = ('~/.local/share' | path expand)
    $env.XDG_CACHE_HOME = ('~/.cache' | path expand)
    $env.EDITOR = if (is-exe nvim) { 'nvim' } else { 'vim' }
    $env.VISUAL = $env.EDITOR
    $env.PAGER = 'bat'
    $env.BAT_THEME = 'Catppuccin Mocha'
    $env.CURRENT_SHELL = 'nu'
}

use aliases.nu *
use list.nu *
use symlink.nu *
use str.nu *
use nix.nu *
use secrets.nu *
use weather.nu *
use file.nu *
use http.nu *
use math.nu
use update.nu *
use kaikki.nu *
use misc.nu *
use macos.nu *
use github.nu *
use license.nu *
use windows.nu
use cookies.nu *
use fun.nu *

use external/wezterm.nu *
use external/bitwarden.nu *
use external/yazi.nu *
use external/tere.nu *
use external/bat.nu *

let nu_config = {
    completions: {
      external: { enable: true max_results: 200 }
      algorithm: 'fuzzy'
    }
    edit_mode: 'vi'
    buffer_editor: "nvim"
    show_banner: false
    cursor_shape: {
      emacs: 'block'
      vi_insert: 'line'
      vi_normal: 'block'
    }
    display_errors: { exit_code: true }
    error_style: 'fancy'
    footer_mode: 'auto'
    history: {
      file_format: 'sqlite'
      isolation: true
    }
    hooks: {
        display_output: { table -e }
    }
    use_kitty_protocol: true
}

$env.config = $env.config | merge $nu_config

$env.config.keybindings ++= [
     {
         name: sanitize_commands
         modifier: control
         keycode: char_t
         mode: [vi_insert vi_normal]
         event: {
             send: executehostcommand,
             cmd: `
                 let new_cmdline = commandline 
                     | lines 
                     | str trim 
                     | str replace -r '^\$\s+' '' 
                     | str replace -ar '\s*&&' '; ' 
                     | str replace -ar '\|\|\s+(true)?' '| ignore; '
                     | each { |line|
                         let parsed = $line | parse 'export {key}={value}' | last
                         if ($parsed | is-not-empty) {
                             $"\$env.($parsed.key) = ($parsed.value)"
                         } else {
                             $line
                         }
                     }
                     | str join "\n"
                 commandline edit --replace $new_cmdline
             `
         }
     }
]

$env.config.hooks.pre_execution ++= [
    { ||
        let cmd = (commandline)
        let clean_cmd = ($cmd 
            | lines
            | str trim
            | str replace -r '^\$\s+' '' 
            | str replace -a '&&' ';'
            | str join "\n"
        )

        if $cmd != $clean_cmd {
            commandline edit --replace $clean_cmd
        }
    }
]
