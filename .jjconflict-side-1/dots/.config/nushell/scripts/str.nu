use std repeat

export def "str repeat" [
    count: int # How many times to repeat
] : string -> string {
    $in | repeat $count | str join
}

export def "str raw-to-double" [] : string -> string {
    let input = $in

    let escaped = $input
        | str replace -a '\' '\\'
        | str replace -a '"' '\"'
        | str replace -a '(' '\('
        | str replace -a '$' '\$'

    $escaped
}
