use external/bitwarden.nu *
use misc.nu is-exe
use std/log

const AGE_PATH = $nu.home-dir | path join '.config/sops/age'
const AGE_KEY_PATH = $AGE_PATH | path join 'keys.txt'
const AGE_KEY_ID = '234609ae-ed35-4975-aacd-b42300b8ea64'

# Setup age keys
export def "secrets setup" [] {
    if not (is-exe bw) {
        error make "bitwarden is not installed"
    }

    let confirm = (input "Don't proceed unless you're on a private machine. Are you sure you want to setup age keys? (y/N) " | str downcase) == 'y'

    if not $confirm {
        print "Aborting"
        return
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
    --save (-s) # Save the encrypted file
    --dest (-d): path # The path to save the encrypted file
] : [nothing -> string, nothing -> nothing] {
    if not (is-exe sops) {
        error make "sops is not installed"
    }

    let keys = parse-age

    if $save and $dest == null {
        log warning $"Saving encrypted file to: ($dest)"
    }
    let default_dest = $file | path parse | upsert extension { |f| 'enc' + if ($f.extension | is-not-empty) { '.' + $f.extension } else { '' } } | path join
    let $dest = $dest | default $default_dest

    let encrypted = ^sops encrypt --age $keys.public $file

    if $save {
        $encrypted | save -f $dest
    } else {
        $encrypted
    }
}

export def "secrets decrypt" [
    file: path, # The file to decrypt
    --save (-s) # Save the decrypted file
    --dest (-d): path # The path to save the decrypted file
] : [nothing -> string, nothing -> nothing] {
    if not (is-exe sops) {
        error make "sops is not installed"
    }
    
    let keys = parse-age

    let decrypted = ^sops decrypt $file

    if $save and $dest == null {
        log warning $"Saving decrypted file to: ($dest)"
    }
    let default_dest = $file | path parse | update extension { |f| $f.extension | str replace '.enc' '' }
    let $dest = $dest | default $default_dest
    
    if $save {
        $decrypted | save -f $dest
    } else {
        $decrypted
    }
}

# Extract email confidentials
export def "secrets extract-emails" [] {
    let bw_items = [
        '73c53e13-cb08-40a4-a846-ae41003e9705'
        '83c6fab2-5fd9-420c-a030-b0ce010cdfa9'
    ]


    let secrets = if ('~/.secrets' | path exists) {
        secrets decrypt ~/.secrets | from json
    } else {
        {}
    }

    let keys = parse-age
    
    let email = $bw_items | each { |it|
        bw get item $it 
        | from json 
        | select name login.username login.password fields 
        | rename name username password fields 
        | update fields { |it| 
            $it.fields 
            | each { |f|
                $f | select name value | transpose -rd 
            }
            | into record
        }
    }
    let email = $email | reject fields | merge $email.fields
    let new_secrets = $secrets | upsert email $email

    $new_secrets | to json | ^sops encrypt --age $keys.public /dev/stdin | save -f ~/.secrets
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
