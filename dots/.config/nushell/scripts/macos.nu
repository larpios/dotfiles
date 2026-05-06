export def "macos cp-file" [...patterns: string] {
    check-macos 

    let files: list<path> = $patterns | par-each { |p| glob $p } | flatten | path expand

    if ($files | is-empty) {
        print "No files matched the provided patterns"
        return
    }

    let script = "on run args
        set sel to {}

        repeat with arg in args
            set f to POSIX file arg
            set end of sel to f
        end repeat

        tell application \"Finder\"
            set the selection to sel
            activate
        end tell

        delay 0.1

        tell application \"System Events\"
            keystroke \"c\" using command down
        end tell
    end run"

    ^osascript -e $script ...$files
}

export def "macos set-wallpaper" [path: string] {
    osascript -e $'tell application "System Events" to set picture of every desktop to POSIX file "($path)"'
}

def check-macos [] {
    if $nu.os-info.name != 'macos' {
        error make 'This command is macOS only'
    }
}
