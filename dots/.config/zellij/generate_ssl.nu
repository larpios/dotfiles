def test-exe [cmd: string] {
  if (which $cmd | is-empty) {
    # Note: Modern Nushell prefers passing a record to error make
    error make {msg: $"Command `($cmd)` is not installed"} 
  }
}

test-exe mkcert

# --- 1. Idempotent Install Check ---
let ca_root = (^mkcert -CAROOT | str trim)
let ca_cert_path = ($ca_root | path join "rootCA.pem")

if not ($ca_cert_path | path exists) {
  print "Installing local CA into system trust store..."
  ^mkcert -install
} else {
  print "Local CA already installed. Skipping..."
}

# --- 2. Safe Path Expansion ---
# This converts ~/.certs to your actual absolute home directory path
let cert_dir = ("~/.certs" | path expand)

if not ($cert_dir | path exists) {
  mkdir $cert_dir
}

# --- 3. Execute with Absolute Paths ---
let key_path = ($cert_dir | path join "zellij-key.pem")
let cert_path = ($cert_dir | path join "zellij.pem")

(
  ^mkcert -key-file $key_path 
  -cert-file $cert_path 
  localhost 127.0.0.1 0.0.0.0
)
