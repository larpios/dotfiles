# Larpi's Dotfiles

Just my personal dotfiles.

## Prerequisites

- Shell (Nushell)
- Jujutsu or Git

## Installation

If you want to try it out, here's how you can do it:

First, clone the repository in `~/.dotfiles`.

Some config files assume the dotfiles repo is in `~/.dotfiles`, usually to share the images in it.

```bash
git clone https://github.com/larpi/dotfiles.git ~/.dotfiles
```

Inside the repository, run the following command:

```bash
cargo +nightly -Zscript setup.rs install
```

You can also dry run it:

```bash
cargo +nightly -Zscript setup.rs install --dry-run
```

---

> [!CAUTION]
> This is not meant to be a distribution, so you should just use it as a reference.

