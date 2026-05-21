use external/bitwarden.nu *
use misc.nu is-exe
use std/log

const AGE_PATH = $nu.home-dir + '/.config/sops/age'

const AGE_KEY_ID = '234609ae-ed35-4975-aacd-b42300b8ea64'
const AGE_KEY_PATH = $AGE_PATH | path join 'keys.txt'

# Setup age keys
export def "secrets setup" [] {
    if not (is-exe bw) {
        error make "bitwarden is not installed"
    }

    if ($AGE_KEY_PATH | path exists) {
        log warning "age key already exists"
    }

    mkdir $AGE_PATH
    bw get notes $AGE_KEY_ID | save -f $AGE_KEY_PATH

    print $"Age key saved to: ($AGE_KEY_PATH)"
}

# Encrypt a file
export def "secrets encrypt" [
    file: path, # The file to encrypt
    --dest (-d): path # The path to save the encrypted file
] {
    if not (is-exe sops) {
        error make "sops is not installed"
    }

    let keys = parse-age

    if $dest == null {
        log warning $"Saving encrypted file to: ($dest)"
    }
    let default_dest = $file | path parse | upsert extension { |f| 'enc' + if ($f.extension | is-not-empty) { '.' + $f.extension } else { '' } } | path join
    let $dest = $dest | default $default_dest

    ^sops encrypt --age $keys.public $file | save -f $dest
}

def parse-age [] : nothing -> record<public: string, private: string> {
    if not ($AGE_KEY_PATH | path exists) {
        error make "age key does not exist. First run 'secret setup'"
    }

    let public_key = open $AGE_KEY_PATH | parse "# public key: {public_key}" | get public_key | last
    let private_key = open $AGE_KEY_PATH | lines | last

    {
        public: $public_key,
        private: $private_key
    }
}
