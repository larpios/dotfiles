export def "file backup" [
    ...files: path,
    --suffix (-s): string = 'bak'
    --timestamp (-t) # Append a timestamp instead of overwriting
] {
    if ($suffix | is-empty) {
        error make {
            msg: $"`suffix` CANNOT be empty"
            labels: [{ text: 'The suffix is empty', span: (metadata $suffix).span }]
        }
    }

    mut overwrite_all = false

    for file in $files {
        if not ($file | path exists) {
            error make {
                msg: $"The file `($file)` does NOT exist"
                labels: [{ text: 'Does NOT exist', span: (metadata $file).span }]
            }
        }

        mut backup = $"($file).($suffix)"

        # Add timestamp dynamically to the backup name
        if $timestamp {
            let ts = (date now | format date "%Y%m%d_%H%M%S")
            $backup = $"($file).($ts).($suffix)"
        } 

        if ($backup | path exists) and not $overwrite_all {
            let options_str = if ($files | length) > 1 { "(y)es/(N)o/(a)ll/(q)uit" } else { "(y)es/(N)o" }
            let confirm = (input $"Do you want to overwrite `($backup)`? [($options_str)]: " | str downcase)

            match $confirm {
                "q" | "quit" => { print 'Aborting backup...'; return }
                "a" | "all" => { $overwrite_all = true }
                "y" | "yes" => {} 
                _ => { print $"Skipping `($file)`..."; continue }
            }
        }

        cp -r $file $backup
    }
}
