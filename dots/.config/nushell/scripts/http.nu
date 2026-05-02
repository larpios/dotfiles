export def "http download" [
    url: string,
    --prefix (-p): string = '.'
    --force (-f)
] {
    let filename = $url | url parse | get path | path basename | url decode
    let target = $prefix | path join $filename
    mkdir $prefix
    if $force and ($target | path exists) {
        rm $target
    }
    http get $url | save $target
    print $"Saved to ($target)"
}
