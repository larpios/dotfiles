def "parse vars" [] {
  $in | from csv --noheaders --no-infer | rename 'op' 'name' 'value'
}

def --env "update-env" [] {
  for $var in $in {
    if $var.op == "set" {
      if ($var.name | str upcase) == 'PATH' {
        $env.PATH = ($var.value | split row (char esep))
      } else {
        load-env {($var.name): $var.value}
      }
    } else if $var.op == "hide" and $var.name in $env {
      hide-env $var.name
    }
  }
}
export-env {
  
  'set,Path,C:\Program Files\PowerShell\7;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\ProgramData\chocolatey\bin;C:\Program Files\Bandizip\;C:\Program Files\PowerShell\7\;C:\Program Files\Git\cmd;C:\Program Files\WezTerm;C:\Program Files\Neovide\;C:\Program Files\Neovim\bin;C:\Program Files\starship\bin\;C:\Users\ray\.cargo\bin;C:\Users\ray\AppData\Local\Microsoft\WindowsApps;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\jj-vcs.jj_Microsoft.Winget.Source_8wekyb3d8bbwe;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\twpayne.chezmoi_Microsoft.Winget.Source_8wekyb3d8bbwe;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\mise\bin;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\Helix.Helix_Microsoft.Winget.Source_8wekyb3d8bbwe\helix-25.07.1-x86_64-windows;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\sharkdp.bat_Microsoft.Winget.Source_8wekyb3d8bbwe\bat-v0.26.1-x86_64-pc-windows-msvc;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\BurntSushi.ripgrep.GNU_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.1.0-x86_64-pc-windows-gnu;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.4.2-x86_64-pc-windows-msvc;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\ajeetdsouza.zoxide_Microsoft.Winget.Source_8wekyb3d8bbwe;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\sxyazi.yazi_Microsoft.Winget.Source_8wekyb3d8bbwe\yazi-x86_64-pc-windows-msvc;C:\Users\ray\AppData\Local\Programs\nu\bin\;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\rsteube.Carapace_Microsoft.Winget.Source_8wekyb3d8bbwe;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\JesseDuffield.lazygit_Microsoft.Winget.Source_8wekyb3d8bbwe;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\Cretezy.lazyjj_Microsoft.Winget.Source_8wekyb3d8bbwe;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\zig.zig_Microsoft.Winget.Source_8wekyb3d8bbwe\zig-x86_64-windows-0.15.2;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\dandavison.delta_Microsoft.Winget.Source_8wekyb3d8bbwe\delta-0.18.2-x86_64-pc-windows-msvc;C:\Users\ray\AppData\Local\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe;C:\Users\ray\AppData\Local\PowerToys\DSCModules\;C:\Users\ray\AppData\Local\Programs\Podman\
hide,MISE_SHELL,
hide,__MISE_DIFF,
hide,__MISE_DIFF,' | parse vars | update-env
  $env.MISE_SHELL = "nu"
  let mise_hook = {
    condition: { "MISE_SHELL" in $env }
    code: { mise_hook }
  }
  add-hook hooks.pre_prompt $mise_hook
  add-hook hooks.env_change.PWD $mise_hook
}

def --env add-hook [field: cell-path new_hook: any] {
  let field = $field | split cell-path | update optional true | into cell-path
  let old_config = $env.config? | default {}
  let old_hooks = $old_config | get $field | default []
  $env.config = ($old_config | upsert $field ($old_hooks ++ [$new_hook]))
}

export def --env --wrapped main [command?: string, --help, ...rest: string] {
  let commands = ["deactivate", "shell", "sh"]

  if ($command == null) {
    ^"C:\\Users\\ray\\AppData\\Local\\Microsoft\\WinGet\\Packages\\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\\mise\\bin\\mise.exe"
  } else if ($command == "activate") {
    $env.MISE_SHELL = "nu"
  } else if ($command in $commands) {
    ^"C:\\Users\\ray\\AppData\\Local\\Microsoft\\WinGet\\Packages\\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\\mise\\bin\\mise.exe" $command ...$rest
    | parse vars
    | update-env
  } else {
    ^"C:\\Users\\ray\\AppData\\Local\\Microsoft\\WinGet\\Packages\\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\\mise\\bin\\mise.exe" $command ...$rest
  }
}

def --env mise_hook [] {
  ^"C:\\Users\\ray\\AppData\\Local\\Microsoft\\WinGet\\Packages\\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\\mise\\bin\\mise.exe" hook-env -s nu
    | parse vars
    | update-env
}

