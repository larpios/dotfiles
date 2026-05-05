#!/usr/bin/env -S cargo +nightly -Zscript
---
[package]
edition = "2024"

[dependencies]
clap = { version = "4.5", features = ["derive"] }
anyhow = "1.0"
which = "8.0"
---

use anyhow::{bail, Context, Result};
use clap::{Parser, Subcommand};
use std::{
    env, fs,
    path,
    process::Command,
    sync::OnceLock,
};
use which::which;

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Install(args) => {
            install(&args)?;
        }
    }
    Ok(())
}

fn install(ctx: &InstallArgs) -> Result<()> {
    if ctx.dry_run {
        println!("Running in dry-run mode, no changes will be made.");
    }

    symlink_in_dir(ctx, "dots", "", Some(&[".config"]))?;
    symlink_in_dir(ctx, "dots", ".config", None)?;

    match env::consts::OS {
        "macos" => {
            let symlinks = [SymlinkSpec::new(
                "~/.config/nushell",
                "~/Library/Application Support/nushell",
            )];
            handle_symlinks(ctx, &symlinks)?;
        }
        "windows" => {
            symlink_in_dir(ctx, "windows/dots", "", Some(&["Documents"]))?;
            symlink_in_dir(ctx, "windows/dots", "Documents", None)?;
        }
        _ => (),
    }

    let repos = [RepoSpec::new(
        "https://github.com/larpios/nvim-config",
        "~/.config/nvim",
    )];

    clone_repos(ctx, &repos)?;

    Ok(())
}

fn handle_symlinks(ctx: &InstallArgs, symlinks: &[SymlinkSpec]) -> Result<()> {
    for symlink in symlinks {
        let src = expand_tilde(&symlink.src)?;
        let dest = expand_tilde(&symlink.dest)?;

        if dest.exists() || dest.symlink_metadata().is_ok() {
            if ctx.force {
                println!("`{}` already exists, overwriting...", dest.display());
                if !ctx.dry_run {
                    remove_file(&dest).with_context(|| "Failed to remove file")?;
                }
            } else {
                println!("`{}` already exists, skipping...", dest.display());
                continue;
            }
        }
        create_symlink(src, dest).with_context(|| {
            format!(
                "Failed to create symlink from {} to {}",
                symlink.src, symlink.dest
            )
        })?;
    }
    Ok(())
}

fn clone_repos(ctx: &InstallArgs, repos: &[RepoSpec]) -> Result<()> {
    let has_jj = which("jj").is_ok();
    let has_git = which("git").is_ok();

    if !has_jj && !has_git {
        bail!("Either jj or git must be installed");
    }

    for repo in repos {
        let dest = expand_tilde(&repo.dest)?;

        if dest.exists() {
            if ctx.force {
                println!("`{}` already exists, overwriting...", dest.display());
                if !ctx.dry_run {
                    remove_file(&dest).with_context(|| "Failed to remove directory")?;
                }
            } else if dest.is_dir() && dest.join(".git").exists() {
                println!("`{}` already exists, skipping...", dest.display());
                continue;
            } else {
                println!("`{}` already exists, backing up...", dest.display());
                if !ctx.dry_run {
                    backup_file(ctx, dest.as_path())?;
                }
            }
        }

        if !ctx.dry_run {
            if has_jj {
                Command::new("jj")
                    .args(["git", "clone", &repo.url, &dest.display().to_string()])
                    .output()
                    .with_context(|| format!("Failed to clone {}", repo.url))?;
            } else {
                Command::new("git")
                    .args(["clone", &repo.url, &dest.display().to_string()])
                    .output()
                    .with_context(|| format!("Failed to clone {}", repo.url))?;
            }
        }
    }

    Ok(())
}

fn symlink_in_dir(
    ctx: &InstallArgs,
    base_dir: impl AsRef<path::Path>,
    relative_path: impl AsRef<path::Path>,
    excludes: Option<&[&str]>,
) -> Result<()> {
    let base = base_dir.as_ref();
    let target = base.join(relative_path);

    if !target.exists() {
        println!("Target does not exist, skipping: {}", target.display());
        return Ok(());
    }

    let home_dir = path::PathBuf::from(
        env::var("HOME")
            .or_else(|_| env::var("USERPROFILE"))
            .context("Failed to get home directory")?,
    );

    for entry in fs::read_dir(&target).with_context(|| "Failed to read directory")? {
        let entry = entry?;
        let path = entry.path();

        let file_name = entry.file_name();

        if let Some(excl) = excludes {
            if excl.contains(&file_name.to_str().unwrap()) {
                continue;
            }
        }

        // Calculate the relative path from the base directory
        let rel_to_base = path.strip_prefix(base).unwrap_or(&path);
        let dest = home_dir.join(rel_to_base);

        if dest.exists() && !dest.is_symlink() {
            if ctx.force {
                println!("`{}` already exists, overwriting...", dest.display());
                remove_file(&dest)?;
            } else {
                println!("`{}` already exists, skipping...", dest.display());
                continue;
            }
        }

        println!("Symlinking {} to {}...", path.display(), dest.display());

        if let Some(parent) = dest.parent() {
            fs::create_dir_all(parent)?;
        }

        if dest.exists() || dest.is_symlink() {
            if ctx.force {
                println!("`{}` already exists, overwriting...", dest.display());
                if !ctx.dry_run {
                    remove_file(&dest)?;
                }
            } else {
                println!("`{}` already exists, backing up...", dest.display());
                backup_file(ctx, &dest)?;
            }
        }

        if !ctx.dry_run {
            let abs_src = path::absolute(&path).unwrap_or(path.clone());
            create_symlink(&abs_src, &dest)
                .with_context(|| format!("Failed to symlink {}", path.display()))?;
        }
    }

    Ok(())
}

fn backup_file(ctx: &InstallArgs, path: &path::Path) -> Result<()> {
    let file_name = path.file_name().context("Path has no filename")?;
    let backup_path = get_backup_dir().join(file_name);

    println!(
        "Moving `{}` to `{}`...",
        path.display(),
        backup_path.display()
    );

    if !ctx.dry_run {
        fs::rename(path, &backup_path).context("Failed to move file to backup")?;
    }

    Ok(())
}

fn expand_tilde(path: &str) -> Result<path::PathBuf> {
    let home_dir = std::env::home_dir().with_context(|| "Failed to get home directory")?;
    let expanded = home_dir.join(path.strip_prefix("~/").unwrap_or(path));
    fs::create_dir_all(expanded.parent().unwrap())?;
    Ok(expanded)
}

fn remove_file(path: &path::Path) -> Result<()> {
    if path.is_dir() {
        fs::remove_dir_all(path).with_context(|| "Failed to remove directory")?;
    } else {
        fs::remove_file(path).with_context(|| "Failed to remove file")?;
    }
    Ok(())
}

#[cfg(not(windows))]
fn create_symlink<T: AsRef<path::Path>>(src: T, dst: T) -> Result<()> {
    std::os::unix::fs::symlink(&src, &dst).with_context(|| {
        format!(
            "Failed to create symlink from {} to {}",
            src.as_ref().display(),
            dst.as_ref().display()
        )
    })
}

#[cfg(windows)]
fn create_symlink<T: AsRef<Path>>(src: T, dst: T) -> Result<()> {
    if src.is_dir() {
        std::os::windows::fs::symlink_dir(&src, &dst).with_context(|| {
            format!(
                "Failed to create symlink from {} to {}",
                src.as_ref().display(),
                dst.as_ref().display()
            )
        })
    } else {
        std::os::windows::fs::symlink_file(&src, &dst).with_context(|| {
            format!(
                "Failed to create symlink from {} to {}",
                src.as_ref().display(),
                dst.as_ref().display()
            )
        })
    }
}

static BACKUP_DIR: OnceLock<path::PathBuf> = OnceLock::new();

fn get_backup_dir() -> &'static path::PathBuf {
    BACKUP_DIR.get_or_init(|| {
        let home = env::var("HOME")
            .or_else(|_| env::var("USERPROFILE"))
            .expect("Could not find home directory");

        let backup_dir = path::PathBuf::from(home).join(".backup");

        if !backup_dir.exists() {
            fs::create_dir_all(&backup_dir).expect("Failed to create backup directory");
        }

        backup_dir
    })
}

#[derive(Parser)]
#[command(name = "dotfiles")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Install(InstallArgs),
}

#[derive(clap::Args)]
struct InstallArgs {
    #[arg(short, long, default_value_t = false)]
    force: bool,
    #[arg(short = 'n', long, default_value_t = false)]
    dry_run: bool,
}

#[derive(Debug, Clone)]
struct RepoSpec {
    url: String,
    dest: String,
}

impl RepoSpec {
    fn new<T, U>(url: T, dest: U) -> Self
    where
        T: ToString,
        U: ToString,
    {
        Self {
            url: url.to_string(),
            dest: dest.to_string(),
        }
    }
}

#[derive(Debug, Clone)]
struct SymlinkSpec {
    src: String,
    dest: String,
}

impl SymlinkSpec {
    fn new<T, U>(src: T, dest: U) -> Self
    where
        T: ToString,
        U: ToString,
    {
        Self {
            src: src.to_string(),
            dest: dest.to_string(),
        }
    }
}
