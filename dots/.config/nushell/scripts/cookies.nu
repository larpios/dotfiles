export def "to netscape-cookies" [
    --expires (-e): datetime
    ] : record -> string {

    let expires = $expires | default ((date now) + 365day * 10)
    let records = $in

    let header = [
        "# Netscape HTTP Cookie File"
        "# http://curl.haxx.se/rfc/cookie_spec.html"
        "# This is a generated file!  Do not edit."
        ""
    ] | str join "\n"

    let cookie_str = $records | items {|key, value|
        $"\tFALSE\t/\tFALSE\t($expires | format date '%s')\t($key)=($value)"
    } | str join "\n"

    [$header $cookie_str] | str join "\n"
}

export def "from cookies" [] : string -> record {
    let input = $in

    $input | split row '; ' | parse '{key}={value}' | transpose -rd
}


export def "from request-header" [] : string -> record {
    let input = $in

    let lines = $input | lines
    let header = $lines | first | parse -r '(\w+)\s+(\S+)\s+(\S+)' | rename method filename protocol | first

    $lines | skip 1 | parse '{key}: {value}' | transpose -rd | merge $header
}
