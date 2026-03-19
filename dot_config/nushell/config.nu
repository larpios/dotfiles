$env.config.completions.external.enable = true
$env.config.completions.external.max_results = 200
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

const CONFIG_DIR: path = $nu.config-path | path dirname
const THEMES_DIR: path = $CONFIG_DIR | path join "themes"
const MODULES_DIR: path = $CONFIG_DIR | path join "modules"
const AUTOLOAD_DIR: path = $CONFIG_DIR | path join "autoload"
const THEME: string = "catppuccin_mocha"
const THEME_FILE: path = $THEMES_DIR | path join $"($THEME).nu"


source-env $THEME_FILE

use aliases.nu *
use list.nu *
use misc.nu *

use windows.nu

source external/init.nu
