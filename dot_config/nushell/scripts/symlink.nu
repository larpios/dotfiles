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
