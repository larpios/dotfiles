$wingetPrograms = @(
    'Ablaze.Floorp', # Browser
    'wez.wezterm.nightly', # Wezterm Nightly, nightly programs probably needs the `--ignore-security-hash` flag
    'Git.Git',
    'Neovim.Neovim.Nightly', # Neovim
    'Helix.Helix',
    'twpayne.chezmoi', # Dotfiles manager
    'Microsoft.PowerShell', # PowerShell 7
    'Starship.Starship',
    'ajeetdsouza.zoxide'
    'sharkdp.bat',
    'sharkdp.fd',
    'sxyazi.yazi',
    'jj-vcs.jj', # Jujutsu version control system
    'jdx.mise', # Mise package manager for devs
    'BurntSushi.ripgrep.GNU',
    'DEVCOM.JetBrainsMonoNerdFont', # JetBrains Mono Nerd Font
    'Neovide.Neovide', # VLC Media Player
    'XnSoft.XnViewMP', # Image viewer
    'VideoLAN.VLC', # VLC Media Player
    'Discord.Discord', # Discord
    'Valve.Steam',
    'Google.Chrome.EXE', # Chrome just in case
    'Kakao.KakaoTalk' # Kakaotalk just in case
)

function Set-UserEnv {
    param(
        [string]$Key,
        [string]$Value
    )
    [System.Environment]::SetEnvironmentVariable($key, $value, "User")
}

Write-Output 'Setting ExecutionPolicy to `Bypass`'
# Allow all PowerShell scripts
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

Write-Output 'Setting XDG_CONFIG_HOME...'
Set-UserEnv -Key "XDG_CONFIG_HOME" -Value "$HOME\.config"

Write-Output 'Installing programs...'
winget install @wingetPrograms --ignore-security-hash
# foreach ($package in $wingetPrograms) {
#     winget install 
    
# }
Write-Output 'Done!'
