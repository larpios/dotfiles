# Swaps two rows in a table
# Usage:
# ```nu
# [ 'a' 'b' 'c' ] | swap 1 2
# # => ['a' 'c' 'b']
# ```
export def "row swap" [
  left: int, # The index of the first row
  right: int # The index of the second row
] : list -> list { if $left >= $in | length { error make {msg: 'Index out of range'} }
if $right >= $in | length { error make {msg: 'Index out of range'} }
if $left == $right { return $in }
let temp = $in.$left
$in | update $left { $in.$right } | update $right { $temp } }
# Moves a row to a specific index
# Usage:
# ```nu
# [ 'a' 'b' 'c' 'd'] | move 1 3
# # => ['a' 'c' 'd' 'b']
export def "row move" [
  from:int, # The indices of the rows to move
  to: int # The index to move the rows to
] : list -> list { if $from >= $in | length { error make {msg: 'Index out of range'} }
if $to >= $in | length { error make {msg: 'Index out of range'} }
if $from == $to { return $in }
let from_val = $in | get $from
mut remove_idx = $from
if $from > $to { $remove_idx = $from + 1 }
$in | insert $to $from_val | drop nth $remove_idx }
