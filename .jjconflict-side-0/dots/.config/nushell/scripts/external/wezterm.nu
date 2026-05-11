use misc.nu is-exe

# Usage: wezterm imgcat [OPTIONS] [FILE_NAME]
# 
# Arguments:
# [FILE_NAME]
# The name of the image file to be displayed. If omitted, will attempt to read it from stdin
# 
# Options:
# --width <WIDTH>
# Specify the display width; defaults to "auto" which automatically selects an appropriate size.  You may also use an integer value `N` to specify the number of cells, or `Npx` to specify the number of pixels, or `N%` to size relative to the terminal width
# 
# --height <HEIGHT>
# Specify the display height; defaults to "auto" which automatically selects an appropriate size.  You may also use an integer value `N` to specify the number of cells, or `Npx` to specify the number of pixels, or `N%` to size relative to the terminal height
# 
# --no-preserve-aspect-ratio
# Do not respect the aspect ratio.  The default is to respect the aspect ratio
# 
# --position <POSITION>
# Set the cursor position prior to displaying the image. The default is to use the current cursor position. Coordinates are expressed in cells with 0,0 being the top left cell position
# 
# --no-move-cursor
# Do not move the cursor after displaying the image. Note that when used like this from the shell, there is a very high chance that shell prompt will overwrite the image; you may wish to also use `--hold` in that case
# 
# --hold
# Wait for enter/escape/ctrl-c/ctrl-d to be pressed after displaying the image
# 
# --tmux-passthru <TMUX_PASSTHRU>
# How to manage passing the escape through to tmux
# 
# [possible values: disable, enable, detect]
# 
# --max-pixels <MAX_PIXELS>
# Set the maximum number of pixels per image frame. Images will be scaled down so that they do not exceed this size, unless `--no-resample` is also used. The default value matches the limit set by wezterm. Note that resampling the image here will reduce any animated images to a single frame
# 
# [default: 25000000]
# 
# --no-resample
# Do not resample images whose frames are larger than the max-pixels value. Note that this will typically result in the image refusing to display in wezterm
# 
# --resample-format <RESAMPLE_FORMAT>
# Specify the image format to use to encode resampled/resized images.  The default is to match the input format, but you can choose an alternative format
# 
# [default: input]
# [possible values: png, jpeg, input]
# 
# --resample-filter <RESAMPLE_FILTER>
# Specify the filtering technique used when resizing/resampling images.  The default is a reasonable middle ground of speed and quality.
# 
# See <https://docs.rs/image/latest/image/imageops/enum.FilterType.html#examples> for examples of the different techniques and their tradeoffs.
# 
# [default: catmull-rom]
# [possible values: nearest, triangle, catmull-rom, gaussian, lanczos3]
# 
# --resize <WIDTHxHEIGHT>
# Pre-process the image to resize it to the specified dimensions, expressed as eg: 800x600 (width x height). The resize is independent of other parameters that control the image placement and dimensions in the terminal; this is provided as a convenience preprocessing step.
# 
# Resizing animated images will reduce the image to a single frame.
# 
# The `--resample-filter` and `--resample-format` options give some control over the quality of the resizing operation and the image format used.
# 
# --show-resample-timing
# When resampling or resizing, display some diagnostics around the timing/performance of that operation
# 
# -h, --help
# Print help (see a summary with '-h')

export def --wrapped wimgcat [
    ...files: path, # The names of the image file to be displayed
    --width (-w): string, # Specify the display width
    --height (-h): string, # Specify the display height
    --no-preserve-aspect-ratio, # Do not respect the aspect ratio
    --position (-p): string, # Set the cursor position prior to displaying the image. The default is to use the current cursor position
    --no-move-cursor, # Do not move the cursor after displaying the image. Note that when used like this from the shell, there is a very high chance that shell prompt will overwrite the image; you may wish to also use `--hold` in that case
    --hold, # Wait for enter/escape/ctrl-c/ctrl-d to be pressed after displaying the image
    --tmux-passthru (-t): string@"nu-complete tmux-passthru", # How to manage passing the escape through to tmux
    --max-pixels: int, # Set the maximum number of pixels. Images will be scaled down so that they do not exceed this size
    --no-resample, # Do not resample images whose frames are larger than the max-pixels value. Note that this will typically result in the image refusing to display in wezterm
    --resample-format (-f): string@"nu-complete resample-format", # Specify the image format to use to encode resampled/resized images. The default is to match the input format
    --resample-filter: string@"nu-complete resample-filter", # Specify the filtering technique used when resizing/resampling images. The default is a reasonable middle ground of speed and quality
    --resize (-r): string, # Pre-process the image to resize it to the specified dimensions, expressed as eg: 800x600 (width x height). The resize is independent of other parameters that control the image placement and dimensions in the terminal; this is provided as a convenience preprocessing step.
    --show-resample-timing, # When resampling or resizing, display some diagnostics around the timing/performance of that operation
    --help (-h), # Print help (see a summary with '-h')
] : [string -> nothing, nothing -> nothing] {
    verify-wezterm

    let input = $in

    let args = [] 
    | append (if ($width | is-not-empty) { ["--width", $width] } else { [] })
    | append (if ($height | is-not-empty) { ["--height", $height] } else { [] })
    | append (if $no_preserve_aspect_ratio { ["--no-preserve-aspect-ratio"] } else { [] })
    | append (if $no_move_cursor { ["--no-move-cursor"] } else { [] })
    | append (if $hold { ["--hold"] } else { [] })
    | append (if ($position | is-not-empty) { ["--position", $position] } else { [] })
    | append (if ($tmux_passthru | is-not-empty) { ["--tmux-passthru", $tmux_passthru] } else { [] })
    | append (if ($max_pixels | is-not-empty) { ["--max-pixels", $max_pixels] } else { [] })
    | append (if $no_resample { ["--no-resample"] } else { [] })
    | append (if ($resample_format | is-not-empty) { ["--resample-format", $resample_format] } else { [] })
    | append (if ($resample_filter | is-not-empty) { ["--resample-filter", $resample_filter] } else { [] })
    | append (if ($resize | is-not-empty) { ["--resize", $resize] } else { [] })
    | append (if ($show_resample_timing | is-not-empty) { ["--show-resample-timing"] } else { [] })

    if ($input | is-not-empty) and ($files | is-empty) {
        $input | ^wezterm imgcat ...$args
    } else {
        for $file in $files {
            let files = glob $file

            for $file in $files {
                ^wezterm imgcat ...$args $file
            }
        }
    }
}

def "nu-complete tmux-passthru" [] {
    ["disable", "enable", "detect"]
}

def "nu-complete resample-format" [] {
    ["png", "jpeg", "input"]
}

def "nu-complete resample-filter" [] {
    ["nearest", "triangle", "catmull-rom", "gaussian", "lanczos3"]
}

def verify-wezterm [] {
    if not (is-exe wezterm) {
        error make "wezterm is not installed"
    }
}
