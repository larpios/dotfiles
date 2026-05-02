use std repeat

export def "str repeat" [
  count: int # How many times to repeat
] : string -> string {
  $in | repeat $count | str join
}
