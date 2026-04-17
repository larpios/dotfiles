const UPDATE_CACHE_FILE = $nu.data-dir | path join 'update-cache.nuon'

# Updates catppuccin themes
export def "nu-update catppuccin" [
    --interval (-i): duration = 1wk # Interval at which to check for updates
] {
    let update_info = check-update "catppuccin"
    if not $update_info.update {
        print $"catppuccin themes are up to date."
        if $update_info.entry_exists {
            print $"last updated: ($update_info.info.update_date)"
            print $"next update: ($update_info.info.update_date + $update_info.info.interval)"
        } else {
            print $"last updated: unknown"
            print $"next update: $"((date now) + $update_info.info.interval)""
        }
        return
    } 

    print "updating catppuccin themes..."

    http 'https://raw.githubusercontent.com/catppuccin/nushell/refs/heads/main/themes/catppuccin_frappe.nu' | save -f ($THEMES_DIR | path join "catppuccin_frappe.nu")
    http 'https://raw.githubusercontent.com/catppuccin/nushell/refs/heads/main/themes/catppuccin_latte.nu' | save -f ($THEMES_DIR | path join "catppuccin_latte.nu")
    http 'https://raw.githubusercontent.com/catppuccin/nushell/refs/heads/main/themes/catppuccin_macchiato.nu' | save -f ($THEMES_DIR | path join "catppuccin_macchiato.nu")
    http 'https://raw.githubusercontent.com/catppuccin/nushell/refs/heads/main/themes/catppuccin_mocha.nu' | save -f ($THEMES_DIR | path join "catppuccin_mocha.nu")

    update-cache "catppuccin" (date now) $interval

    print "catppuccin themes updated."
}

def update-cache [
    name: string
    update_date: datetime 
    interval: duration
] {
    mkdir ($UPDATE_CACHE_FILE | path dirname)
    if not ($UPDATE_CACHE_FILE | path exists) {
        {
            $name: { 
                update_date: $update_date
                interval: $interval
            }
        } | save -f $UPDATE_CACHE_FILE
        return
    }

    let cache = open $UPDATE_CACHE_FILE
    $cache | merge { 
        $name: {
            update_date: $update_date
            interval: $interval
        } 
    } | save -f $UPDATE_CACHE_FILE
}

# Returns true if update is required
#
# Checks update cache for the update date and compares it to current date
# If we are past the update date, `update` is `true`
#
# If the update cache or the entry in the update cache does not exist, `update` is `true` to force an update
def check-update [
    name: string # Module name to check
] : nothing -> record<update: bool, entry_exists: bool, update_date?: datetime> {
    if not ($UPDATE_CACHE_FILE | path exists) {
        return {
            update: true
            entry_exists: false
        }
    }

    let cache = open $UPDATE_CACHE_FILE

    let date = $cache | get -o $name
    if $date == null {
        {
            update: true
            entry_exists: false
        }
    } else {
        let update_date = $date.update_date + $date.interval
        {
            update: ($update_date <= (date now))
            entry_exists: true
            info: $date
        }
    }
}
