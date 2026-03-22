# Commands for working with symbolic links


export def "is-symlink" [] : path -> bool {
  if not ($in | path exists) {
    error make {
      msg: $"($in) does not exist"
      labels: [
        {
          text: 'Path does not exist'
          span: (metadata $in).span
        }
      ]
    }
  }

  let type = (ls -l $in | last | get type)

  $type == 'symlink'
}

export def "symlink follow" [] : [path -> path, list<path> -> list<path>] {
  let path_input = $in

  if ($path_input | describe | str contains 'list') {
    return ($path_input | each { symlink follow })
  }

  if ($path_input | is-empty) {
    return ''
  }

  if not ($path_input | path exists) {
    error make {
      msg: $"($path_input) does not exist"
      labels: [
        {
          text: 'Path does not exist'
          span: (metadata $path_input).span
        }
      ]
    }
  }
  if not ($path_input | is-symlink) {
    error make {
      msg: $"($path_input) is not a symlink"
      labels: [
        {
          text: 'Path is not a symlink'
          span: (metadata $path_input).span
        }
      ]
    }
  }

  $in | path expand
}

# Convert a symlink to its target file
export def "symlink to-target" [link: path] {
  let target = $link | symlink follow 

  rm $link
  cp $target $link
}
