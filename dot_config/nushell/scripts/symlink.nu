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

export def "symlink follow" [] : path -> path {
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
  if not ($in | is-symlink) {
    error make {
      msg: $"($in) is not a symlink"
      labels: [
        {
          text: 'Path is not a symlink'
          span: (metadata $in).span
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
