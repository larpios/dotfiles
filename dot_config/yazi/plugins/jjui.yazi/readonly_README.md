# lazygit.yazi

Plugin for [Yazi](https://github.com/sxyazi/yazi) to manage [jujutsu](https://github.com/jj-vcs/jj) repos with [jjui](https://github.com/idursun/jjui).

## Dependencies

Make sure [jjui](https://github.com/idursun/jjui) and [jujutsu](https://github.com/jj-vcs/jj) is installed and in your `PATH`.

## Installation

### Using `ya pkg`

```shell
 ya pkg add Adda0/jjui
```

### Manual

**Linux/macOS**

```shell
git clone https://github.com/Adda0/jjui.yazi.git ~/.config/yazi/plugins/jjui.yazi
```

**Windows**

```shell
git clone https://github.com/Adda0/jjui.yazi.git %AppData%\yazi\config\plugins\jjui.yazi
```

## Configuration

Add the following to your **keymap.toml** file:

```toml
[[mgr.prepend_keymap]]
on   = [ "g", "j" ]
run  = "plugin jjui"
desc = "run jjui"
```

You can customize the keybinding however you like. Please refer to the [keymap.toml](https://yazi-rs.github.io/docs/configuration/keymap) documentation.

## Disclaimer

**THIS PLUGIN IS FOR THE STABLE RELEASE OF YAZI, DON'T PROPOSE ANY CHANGES BASED ON PRE-RELEASES OF YAZI.**
