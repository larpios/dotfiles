export def query [
    expression: string
    --language (-l): string@"nu-complete language" = "Any"
    --source-language (-s): string@"nu-complete language" = "English"
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

    try {
        http $url | decode | lines | each { from json }
    } catch {
        print $"No entry for `($expression)`"
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

