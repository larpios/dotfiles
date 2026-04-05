# Bitwarden CLI (bw) Nushell Completions

export extern "bw" [
    ...args: string
    --pretty                    # Format output. JSON is tabbed with two spaces.
    --raw                       # Return raw output instead of a descriptive message.
    --response                  # Return a JSON formatted version of response output.
    --cleanexit                 # Exit with a success exit code (0) unless an error is thrown.
    --quiet                     # Don't return anything to stdout.
    --nointeraction             # Do not prompt for interactive user input.
    --session: string           # Pass session key instead of reading from env.
    --version(-v)               # output the version number
    --help(-h)                  # output usage information
]

# Print the SDK version.
export extern "bw sdk-version" [
    ...args: string
]

# Log into a user account.
export extern "bw login" [
    ...args: string
    --method: string            # Two-step login method.
    --code: string              # Two-step login code.
    --sso                       # Log in with Single-Sign On with optional organization identifier.
    --apikey                    # Log in with an Api Key.
    --passwordenv: string       # Environment variable storing your password
    --passwordfile: string      # Path to a file containing your password as its first line
    --check                     # Check login status.
    --help(-h)                  # output usage information
]

# Log out of the current user account.
export extern "bw logout" [
    ...args: string
]

# Lock the vault and destroy active session keys.
export extern "bw lock" [
    ...args: string
]

# Unlock the vault and return a new session key.
export extern "bw unlock" [
    ...args: string
    --check                     # Check lock status.
    --passwordenv: string       # Environment variable storing your password
    --passwordfile: string      # Path to a file containing your password as its first line
    --help(-h)                  # output usage information
]

# Pull the latest vault data from server.
export extern "bw sync" [
    ...args: string
    --force(-f)                 # Force a full sync.
    --last                      # Get the last sync date.
    --help(-h)                  # output usage information
]

# Generate a password/passphrase.
export extern "bw generate" [
    ...args: string
    --uppercase(-u)             # Include uppercase characters.
    --lowercase(-l)             # Include lowercase characters.
    --number(-n)                # Include numeric characters.
    --special(-s)               # Include special characters.
    --passphrase(-p)            # Generate a passphrase.
    --length: int               # Length of the password.
    --words: int                # Number of words.
    --minNumber: int            # Minimum number of numeric characters.
    --minSpecial: int           # Minimum number of special characters.
    --separator: string         # Word separator.
    --capitalize(-c)            # Title case passphrase.
    --includeNumber             # Passphrase includes number.
    --ambiguous                 # Avoid ambiguous characters.
    --help(-h)                  # output usage information
]

# Base 64 encode stdin.
export extern "bw encode" [
    ...args: string
]

# Configure CLI settings.
export extern "bw config" [
    ...args: string
    --web-vault: string         # Provides a custom web vault URL that differs from the base URL.
    --api: string               # Provides a custom API URL that differs from the base URL.
    --identity: string          # Provides a custom identity URL that differs from the base URL.
    --icons: string             # Provides a custom icons service URL that differs from the base URL.
    --notifications: string     # Provides a custom notifications URL that differs from the base URL.
    --events: string            # Provides a custom events URL that differs from the base URL.
    --key-connector: string     # Provides the URL for your Key Connector server.
    --help(-h)                  # output usage information
]

# Check for updates.
export extern "bw update" [
    ...args: string
]

# Generate shell completions.
export extern "bw completion" [
    ...args: string
    --shell: string             # Shell to generate completions for.
    --help(-h)                  # output usage information
]

# Show server, last sync, user information, and vault status.
export extern "bw status" [
    ...args: string
]

# List an array of objects from the vault.
export extern "bw list" [
    ...args: string
    --search: string            # Perform a search on the listed objects.
    --url: string               # Filter items of type login with a url-match search.
    --folderid: string          # Filter items by folder id.
    --collectionid: string      # Filter items by collection id.
    --organizationid: string    # Filter items or collections by organization id.
    --trash                     # Filter items that are deleted and in the trash.
    --archived                  # Filter items that are archived.
    --help(-h)                  # output usage information
]

# Get an object from the vault.
export extern "bw get" [
    ...args: string
    --itemid: string            # Attachment's item id.
    --output: string            # Output directory or filename for attachment.
    --organizationid: string    # Organization id for an organization object.
    --help(-h)                  # output usage information
]

# Create an object in the vault.
export extern "bw create" [
    ...args: string
    --file: string              # Path to file for attachment.
    --itemid: string            # Attachment's item id.
    --organizationid: string    # Organization id for an organization object.
    --help(-h)                  # output usage information
]

# Edit an object from the vault.
export extern "bw edit" [
    ...args: string
    --organizationid: string    # Organization id for an organization object.
    --help(-h)                  # output usage information
]

# Delete an object from the vault.
export extern "bw delete" [
    ...args: string
    --itemid: string            # Attachment's item id.
    --organizationid: string    # Organization id for an organization object.
    --permanent(-p)             # Permanently deletes the item instead of soft-deleting it (item only).
    --help(-h)                  # output usage information
]

# Restores an object from the trash or archive.
export extern "bw restore" [
    ...args: string
]

# Move an item to an organization.
export extern "bw move" [
    ...args: string
]

# Confirm an object to the organization.
export extern "bw confirm" [
    ...args: string
    --organizationid: string    # Organization id for an organization object.
    --help(-h)                  # output usage information
]

# Import vault data from a file.
export extern "bw import" [
    ...args: string
    --formats                   # List formats
    --organizationid: string    # ID of the organization to import to.
    --help(-h)                  # output usage information
]

# Export vault data to a CSV, JSON or ZIP file.
export extern "bw export" [
    ...args: string
    --output: string            # Output directory or filename.
    --format: string            # Export file format.
    --password: string          # Use password to encrypt instead of your Bitwarden account encryption key. Only applies to the encrypted_json format.
    --organizationid: string    # Organization id for an organization.
    --help(-h)                  # output usage information
]

# --DEPRECATED-- Move an item to an organization.
export extern "bw share" [
    ...args: string
]

# Archive an object from the vault.
export extern "bw archive" [
    ...args: string
]

# Work with Bitwarden sends. A Send can be quickly created using this command or subcommands can be used to fine-tune the Send
export extern "bw send" [
    ...args: string
    --file(-f): string          # Specifies that <data> is a filepath
    --deleteInDays(-d): int     # The number of days in the future to set deletion date, defaults to 7
    --password: string          # optional password to access this Send. Can also be specified in JSON.
    --emails: string            # optional emails to access this Send. Can also be specified in JSON.
    --maxAccessCount(-a): int   # The amount of max possible accesses.
    --hidden                    # Hide <data> in web by default. Valid only if --file is not set.
    --name(-n): string          # The name of the Send. Defaults to a guid for text Sends and the filename for files.
    --notes: string             # Notes to add to the Send.
    --fullObject                # Specifies that the full Send object should be returned rather than just the access url.
    --help(-h)                  # output usage information
]

export extern "bw send list" [
    ...args: string
]

export extern "bw send template" [
    ...args: string
]

export extern "bw send get" [
    ...args: string
    --output: string            # Output directory or filename for attachment.
    --text                      # Specifies to return the text content of a Send
    --help(-h)                  # output usage information
]

export extern "bw send receive" [
    ...args: string
    --password: string          # Password needed to access the Send.
    --passwordenv: string       # Environment variable storing the Send's password
    --passwordfile: string      # Path to a file containing the Sends password as its first line
    --obj                       # Return the Send's json object rather than the Send's content
    --output: string            # Specify a file path to save a File-type Send to
    --help(-h)                  # output usage information
]

export extern "bw send create" [
    ...args: string
    --file: string              # file to Send. Can also be specified in parent's JSON.
    --text: string              # text to Send. Can also be specified in parent's JSON.
    --hidden                    # text hidden flag. Valid only with the --text option.
    --help(-h)                  # output usage information
]

export extern "bw send edit" [
    ...args: string
    --itemid: string            # Overrides the itemId provided in [encodedJson]
    --help(-h)                  # output usage information
]

export extern "bw send remove-password" [
    ...args: string
]

export extern "bw send delete" [
    ...args: string
]

# Access a Bitwarden Send from a url
export extern "bw receive" [
    ...args: string
    --password: string          # Password needed to access the Send.
    --passwordenv: string       # Environment variable storing the Send's password
    --passwordfile: string      # Path to a file containing the Sends password as its first line
    --obj                       # Return the Send's json object rather than the Send's content
    --output: string            # Specify a file path to save a File-type Send to
    --help(-h)                  # output usage information
]

# Start a RESTful API webserver.
export extern "bw serve" [
    ...args: string
    --hostname: string          # The hostname to bind your API webserver to.
    --port: int                 # The port to run your API webserver on.
    --disable-origin-protection # If set, allows requests with origin header. Warning, this option exists for backwards compatibility reasons and exposes your environment to known CSRF attacks.
    --help(-h)                  # output usage information
]

