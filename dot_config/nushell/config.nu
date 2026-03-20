$env.config.completions.external.enable = true
$env.config.completions.external.max_results = 200
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

const CONFIG_DIR = $nu.config-path | path dirname
const THEMES_DIR = $CONFIG_DIR | path join "themes"
const MODULES_DIR = $CONFIG_DIR | path join "modules"
const AUTOLOAD_DIR = $CONFIG_DIR | path join "autoload"

const THEME = "catppuccin_mocha"
const THEME_FILE = $THEMES_DIR | path join $"($THEME).nu"
source-env $THEME_FILE

use aliases.nu *
use list.nu *
use misc.nu *
use external.nu *
use windows.nu
