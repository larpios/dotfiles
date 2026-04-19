export def query [
    expression: string
    --language (-l): string@"nu-complete language" = "Any"
    --source-language (-s): string@"nu-complete language" = "English"
    --raw (-r) # Whether to skip processing
] : nothing -> record {
    if ($expression | is-empty) {
        error make {
            msg: 'expression cannot be empty'
            labels: [
                {
                    text: 'empty',
                    span: (metadata $expression).span
                }
            ]
        }
    }

    if not ($language in (nu-complete language)) {
        error make {
            msg: 'provided language is not supported'
            labels: [
                {
                    text: 'unsupported language',
                    span: (metadata $language).span
                }
            ]
        }
    }

    let p1 = $expression | str substring 0..0
    let p2 = $expression | str substring 0..1
    let dict = match $source_language {
        "Czech"          => "cswiktionary",
        "Dutch"          => "nlwiktionary",
        "English"        => "dictionary",
        "Finnish"        => "fiwiktionary",
        "French"         => "frwiktionary",
        "German"         => "dewiktionary",
        "Greek"          => "elwiktionary",
        "Indonesian"     => "idwiktionary",
        "Italian"        => "itwiktionary",
        "Japanese"       => "jawiktionary",
        "Korean"         => "kowiktionary",
        "Kurdish"        => "kuwiktionary",
        "Malay"          => "mswiktionary",
        "Polish"         => "plwiktionary",
        "Portuguese"     => "ptwiktionary",
        "Simple English" => "simplewiktionary",
        "Spanish"        => "eswiktionary",
        "Swedish"        => "svwiktionary",
        "Turkish"        => "trwiktionary",
        "Vietnamese"     => "viwiktionary",
        _                => "dictionary"
    }
    let lang = if $language == "Any" {
        "All languages combined"
    } else {
        $language
    }
    let url = $"https://kaikki.org/($dict)/($lang)/meaning/($p1)/($p2)/($expression).jsonl" | url encode

    let raw_response = try {
        http $url
    } catch { |err|
        let err_raw = ($err.json | from json | get labels.text | last)
        if $err_raw =~ '404' {
            print $"(ansi yellow)No entry for `($expression)`(ansi reset)"
            return
        } else {
            error make $err
        }
        return
    }
    let data = $raw_response | decode | lines | each { from json }

    if $raw {
        $data
    } else {
        let processed = $data
        | select senses pos word lang 
        | flatten 
        | group-by lang 
        | transpose lang entries
        | update entries { |lang_row|
            $lang_row.entries
            | group-by pos
            | transpose pos items
            | update items { |pos_row|
                $pos_row.items | each { |row|
                    {
                        senses: ($row.senses.glosses? | default [] | flatten)
                        examples: (try { $row.senses.examples.text } catch { [] })
                    }
                }
                # $pos_row.items | get senses.glosses? | flatten
            }
            | transpose -rd
        }
        | transpose -rd

        $processed
    }
}

def "nu-complete language" [] {
    [
        "Arabic"
        "Bengali"
        "Czech"
        "Dutch"
        "English"
        "Finnish"
        "French"
        "German"
        "Greek"
        "Indonesian"
        "Italian"
        "Japanese"
        "Korean"
        "Kurdish"
        "Malay"
        "Polish"
        "Portuguese"
        "Russian"
        "Simple English"
        "Spanish"
        "Swedish"
        "Tamil"
        "Telugu"
        "Thai"
        "Vietnamese"
        "Any"
        ]
}

