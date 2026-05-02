use misc.nu is-exe
use http.nu 'http download'

export def "update bat" [] {
    if not (is-exe bat) {
        error make '`bat` is not installed'
    }
    let themes_dir = ^bat --config-dir | path join 'themes'
    mkdir $themes_dir
    const FILE_URLS = [
        'https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme'
        'https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme'
        'https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme'
        'https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme'
    ]
    for url in $FILE_URLS {
        http download --force $url --prefix $themes_dir
    }

    bat cache --build
}

export-env { 
    $env.BAT_THEME = 'Catppuccin Mocha'
}

