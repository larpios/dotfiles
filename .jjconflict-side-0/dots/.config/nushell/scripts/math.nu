export def is-multiple-of [n: int] : [int -> bool, list<int> -> list<bool>] {
    let input = $in

    let type = $input | describe

    if $type =~ 'list' {
        $input | each { is-multiple-of $n }
    } else {
        $input mod $n == 0
    }
}

export def is-not-multiple-of [n: int] : [int -> bool, list<int> -> list<bool>] {
    $in | each { |num| not ($num | is-multiple-of $n) }
}

export alias is-divisible-by = is-multiple-of
export alias is-even = is-multiple-of 2
export alias is-odd = is-not-multiple-of 2
