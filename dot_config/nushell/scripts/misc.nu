use std/assert
use std/log

export def is-exe [cmd?: string] { 
  if ($cmd == null and $in == null) {
    error make {
      msg: 'No arguments provided'
      labels: [
        {
          text: 'No regular or piped argument provided'
          span: (metadata $cmd).span
        }
      ]
    }
  } else if ($cmd != null and $in != null) {
    error make {
      msg: 'Too many arguments provided'
      labels: [
        {
          text: 'Regular argument provided'
          span: (metadata $cmd).span
        },
        {
          text: 'Piped argument provided'
          span: (metadata $in).span
        }
      ]
    } 
  } else if ($in != null) {
    return (is-exe $in)
  }

  assert not equal $cmd null 'You should have already checked for arguments'

  log debug $"Checking if `($cmd)` is an executable"
  which $cmd | is-not-empty 
}
