# Copy file and add certain suffix
export def "file backup" [
  src: path,
  --suffix (-s): string = 'bak'
  --increment (-i) # Increment backup files with same suffix
] {
  if not ($src | path exists) {
    error make {
      msg :$"The file `($src)` does NOT exist"
      labels: [
        {
          text: 'Does NOT exists'
          span: (metadata $src).span
        }
      ]
    }
  }

  if ($suffix | is-empty) {
    error make {
      msg: $"`extension` CANNOT be empty`"
      labels: [
        {
          text: 'The extension is empty'
          span: (metadata $suffix).span
        }
      ]
    }
  }

  mut backup = $src | path parse | upsert extension { |p| $p.extension + '.' + $suffix } | path join

  if ($backup | path exists) {
    if $increment {
      let last_bak_ext = glob $"($backup)*" | sort | last | path parse | get extension
      mut new_ext = ''
      if $last_bak_ext =~ '(\d+)$' {
        let new_num = ($last_bak_ext | parse -r ($suffix + '(\d+)$') | last | get capture0 | into int) + 1
        $new_ext = $"($suffix)($new_num)"
      } else {
        $new_ext = ($backup | path parse | get extension) + '1'
      }
      $backup = $backup | path parse | upsert extension $new_ext | path join
    } else {
      let confirm = input $"Do you want to overwrite the existing backup file `($backup)`? [y/N]"
      if ($confirm | str downcase) != 'y' {
        print "Abort backing up"
        return
      }
    }
  }

  print $"Copying ($src) into ($backup)..."
  cp $src $backup
}

