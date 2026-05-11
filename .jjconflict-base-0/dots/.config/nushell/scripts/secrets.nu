use external/bitwarden.nu *
use misc.nu is-exe
use std/log

const AGE_PATH = $nu.home-dir + '/.config/sops/age'

const AGE_KEY_ID = '234609ae-ed35-4975-aacd-b42300b8ea64'
const AGE_KEY_PATH = $AGE_PATH | path join 'keys.txt'
const CHEZMOI_CONFIG_PATH = $nu.home-dir + '/.config/chezmoi/chezmoi.toml'

# Setup age keys
export def "secret setup" [] {
  if not (is-exe bw) {
    error make "bitwarden is not installed"
  }

  if ($AGE_KEY_PATH | path exists) {
    log warning "age key already exists"
  }

  mkdir $AGE_PATH
  bw get notes $AGE_KEY_ID | save -f $AGE_KEY_PATH

  print $"Age key saved to: ($AGE_KEY_PATH)"

  mut chezmoi_config = open $CHEZMOI_CONFIG_PATH | default {}

  $chezmoi_config = $chezmoi_config | merge {
    encryption: 'age',
    age: {
      identity: $AGE_KEY_PATH
      recipient: (parse-age).public
    }
  }

  $chezmoi_config | to toml | save -f $CHEZMOI_CONFIG_PATH
  print $"chezmoi config saved to: ($CHEZMOI_CONFIG_PATH)"
}

# Encrypt a file
export def "secret encrypt" [
  $file: path, # The file to encrypt
  $dest: oneof<path, nothing> = null, # The path to save the encrypted file
] {
  if not (is-exe sops) {
    error make "sops is not installed"
  }

  let keys = parse-age

  mut $dest = $dest
  if $dest == null {
    $dest = $file | path parse | upsert extension { |f| 'enc' + if ($f.extension | is-not-empty) { '.' + $f.extension } else { '' } } | path join
    log warning $"Saving encrypted file to: ($dest)"
  }
  
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
