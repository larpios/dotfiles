if status is-interactive 
    # Disable start message
    set fish_greeting
    # Enable transient prompt
    set -g fish_transient_prompt 1

    # Enable VI mode
    fish_vi_key_bindings
    fish_vi_cursor

    source "$__fish_config_dir/functions.fish"
    source "$__fish_config_dir/aliases.fish"
    source "$__fish_config_dir/external.fish"
    source "$__fish_config_dir/exports.fish"
    source "$__fish_config_dir/plugins.fish"
end
