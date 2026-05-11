const GITHUB_USERNAME = 'larpios'
const GITHUB_EMAIL = '33772093+larpios@users.noreply.github.com'

export-env {
    $env.GITHUB_USERNAME = $GITHUB_USERNAME
    $env.GITHUB_EMAIL = $GITHUB_EMAIL
    $env.GITHUB_HTTP = $"https://github.com/($GITHUB_USERNAME)"
    $env.GITHUB_SSH = $"git@github.com:($GITHUB_USERNAME)"
}

# Return the URL of a GitHub repository
#
# By default, the user is me, but it can be overridden with the --user flag
export def "github get-url" [
    repo: string
    --user (-u): string 
    --protocol (-p): string@"nu-complete protocol" = 'https'
] {
    let user = $user | default $env.GITHUB_USERNAME

    match $protocol {
        'https' => $"https://github.com/($user)/($repo)"
        'ssh' => $"git@github.com:($user)/($repo)"
    }
}

def "nu-complete protocol" [] {
    [
        'https'
        'ssh'
    ]
}
