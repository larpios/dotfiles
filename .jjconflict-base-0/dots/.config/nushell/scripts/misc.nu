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

# Use piped argument as regular argument.  
export def with [action: closure] : any -> any {
  let input = $in
  do $action $input
}

# Run a closure in a specific directory
export def within [
    cwd: path, # Where to run closure in
    ...args, # Commands to run, or closure to run
# action: closure, # Closure to run
] : any -> any {
    let input = $in
    do {
        cd $cwd
        if ($args | length) == 1 and ($args.0 | describe) =~ 'closure' {
            do $args.0 $input
        } else {
            nu -c ($args | str join ' ')
        }
    }
}

export def psub [
    --timeout (-t): duration = 10sec, # Timeout for the spawned process
] : any -> path {
    let input = $in

    let tmp = mktemp

    $input | save -f $tmp

    job spawn {
        sleep $timeout
        rm $tmp
    }

    $tmp
}

export def export-compat [
    entry: string
] {
    let pair = $entry | parse '{key}={value}'

    let key = $pair.key
    let value = $pair.value

    export-env {
        $env.$key = $value
    }
}

export def export-from-sh [
    code: string
] {
    $code
    | lines
    | where { |line|
        $line | str starts-with 'export'
    } 
    | each { |line|
        export-compat ($line | str trim -l -c "export ")
    }
}
