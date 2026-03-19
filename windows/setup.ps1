$wingetPrograms = @(
    'Ablaze.Floorp' # Browser
    'wez.wezterm.nightly' # Wezterm Nightly, nightly programs probably needs the `--ignore-security-hash` flag
    'Git.Git'
    'Neovim.Neovim.Nightly' # Neovim
    'Helix.Helix'
    'twpayne.chezmoi' # Dotfiles manager
    'Microsoft.PowerShell' # PowerShell 7
    'Starship.Starship'
    'ajeetdsouza.zoxide'
    'dandavison.delta'
    'sharkdp.bat'
    'sharkdp.fd'
    'LLVM.LLVM'
    'MSYS2.MSYS2' # gcc
    'Microsoft.VisualStudio.BuildTools'
    'zig.zig'
    'sxyazi.yazi'
    'junegunn.fzf'
    'Raycast' # Task runner
    'jj-vcs.jj' # Jujutsu version control system
    'jdx.mise' # Mise package manager for devs
    'BurntSushi.ripgrep.GNU'
    'DEVCOM.JetBrainsMonoNerdFont' # JetBrains Mono Nerd Font
    'Nushell.Nushell'
    'rsteube.Carapace'
    'JesseDuffield.lazygit'
    'Cretezy.lazyjj'
    'Microsoft.PowerToys'
    'Neovide.Neovide' # VLC Media Player
    'XnSoft.XnViewMP' # Image viewer
    'VideoLAN.VLC' # VLC Media Player
    'Discord.Discord' # Discord
    'Valve.Steam'
    'Google.Chrome.EXE' # Chrome just in case
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
#
Write-Output 'Setting SHELL...'
Set-UserEnv -Key "SHELL" -Value (Get-Command nu).Path

Write-Output 'Setting EDITOR...'
Set-UserEnv -Key "EDITOR" -Value 'nvim'
Set-UserEnv -Key "VISUAL" -Value 'nvim'
    
# }
Write-Output 'Done!'
