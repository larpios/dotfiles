if status is-interactive 
    # Disable start message
    set fish_greeting

    source "$__fish_config_dir/functions.fish"
    source "$__fish_config_dir/aliases.fish"
    source "$__fish_config_dir/external.fish"
end
