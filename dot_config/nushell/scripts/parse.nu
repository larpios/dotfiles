use str.nu *

export def "to nix" [
  --indent (-i): int = 2 # Number of spaces to use for each indentation level
] : any -> string {
  let input = $in
  _to_nix $input 0 $indent
}

# Recursive helper function
def _to_nix [val: any, level: int, indent_step: int]: any -> string {
  let type_str = ($val | describe)
  let pad = (" " | str repeat ($level * $indent_step))
  let inner_pad = (" " | str repeat (($level + 1) * $indent_step))

  if ($type_str == "nothing") {
    "null"
        } else if ($type_str == "bool") {
            if $val { "true" } else { "false" }
        } else if ($type_str == "int" or $type_str == "float") {
            ($val | into string)
        } else if ($type_str == "string") {
            # Escape backslashes and double quotes for standard Nix strings
            let escaped = ($val | str replace -a '"' '\"')
            $"\"($escaped)\""
        } else if ($type_str | str starts-with "list") {
          if ($val | is-empty) { 
            "[]" 
            } else {
                let items = ($val | each { |it|
                    let parsed = (_to_nix $it ($level + 1) $indent_step)
                    $"($inner_pad)($parsed)"
                } | str join "\n")
                $"[\n($items)\n($pad)]"
            }
        } else if ($type_str | str starts-with "record") {
            if ($val | is-empty) { 
                "{}" 
            } else {
                let items = ($val | columns | each { |key|
                    let v = ($val | get $key)
                    let parsed = (_to_nix $v ($level + 1) $indent_step)

# Nix allows unquoted keys if they match certain regex, otherwise they need quotes
                    let safe_key = if ($key =~ '^[a-zA-Z\_][a-zA-Z0-9\_\-]*$') { 
                      $key 
                    } else { 
                      $"\"($key)\"" 
                    }

                    $"($inner_pad)($safe_key) = ($parsed);"
                } | str join "\n")
                $"{\n($items)\n($pad)}"
            }
        } else {
# Fallback for Nushell types that don't map cleanly to Nix (e.g., closures, durations)
          $"\"<unsupported nushell type: ($type_str)>\""
        }
}
