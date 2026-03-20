use std/assert
use std/log

# Check if a command is an executable.
#
# The standard way is to pass the command as a regular argument, but it can also be piped.
#
# @error: If none or both of them are provided, an error is raised.
export def is-exe [cmd?: string] : [nothing -> bool, string -> bool] { 
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
      help: ([
        'Try using just a regular argument or just a piped argument'
        ('is-exe cmd' | nu-highlight)
        'or'
        ('"cmd" | is-exe' | nu-highlight)
      ] | str join "\n")
    } 
  } else if ($in != null) {
    is-exe $in
  } else {
    log debug $"Checking if `($cmd)` is an executable"
    which $cmd | is-not-empty 
  }
}
