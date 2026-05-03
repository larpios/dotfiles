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
    path::{Path, PathBuf},
    process::Command,
    sync::OnceLock,
};
use which::which;

#[cfg(not(windows))]
fn create_symlink<T: AsRef<Path>>(src: T, dst: T) -> Result<()> {
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

static BACKUP_DIR: OnceLock<PathBuf> = OnceLock::new();

fn get_backup_dir() -> &'static PathBuf {
    BACKUP_DIR.get_or_init(|| {
        let home = env::var("HOME")
            .or_else(|_| env::var("USERPROFILE"))
            .expect("Could not find home directory");

        let backup_dir = PathBuf::from(home).join(".backup");

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
struct Repos {
    url: String,
    dest: String,
}

impl Repos {
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
        "macos" => symlink_in_dir(ctx, "macos/dots", "Library/Application Support", None)?,
        "windows" => symlink_in_dir(ctx, "windows/dots", "Documents", None)?,
        _ => (),
    }

    let repos = [Repos::new(
        "https://github.com/larpios/nvim-config",
        "~/.config/nvim",
    )];

    clone_repos(ctx, &repos)?;

    Ok(())
}

fn clone_repos(ctx: &InstallArgs, repos: &[Repos]) -> Result<()> {
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
                    fs::remove_dir_all(&dest).with_context(|| "Failed to remove directory")?;
                }
            } else if dest.is_dir() && dest.join(".git").exists() {
                println!("`{}` already exists, skipping...", dest.display());
                continue;
            } else {
                println!("`{}` already exists, backing up...", dest.display());
                if !ctx.dry_run {
                    backup_file(ctx, &dest.as_path())?;
                }
            }
        }

        if !ctx.dry_run {
            if has_jj {
                Command::new("jj")
                    .args(&["git", "clone", &repo.url, &dest.display().to_string()])
                    .output()
                    .with_context(|| format!("Failed to clone {}", repo.url))?;
            } else {
                Command::new("git")
                    .args(&["clone", &repo.url, &dest.display().to_string()])
                    .output()
                    .with_context(|| format!("Failed to clone {}", repo.url))?;
            }
        }
    }

    Ok(())
}

fn symlink_in_dir(
    ctx: &InstallArgs,
    base_dir: impl AsRef<Path>,
    relative_path: impl AsRef<Path>,
    excludes: Option<&[&str]>,
) -> Result<()> {
    let base = base_dir.as_ref();
    let target = base.join(relative_path);

    if !target.exists() {
        println!("Target does not exist, skipping: {}", target.display());
        return Ok(());
    }

    let home_dir = PathBuf::from(
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
                fs::remove_dir_all(&dest)?;
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
                    fs::remove_file(&dest)?;
                }
            } else {
                println!("`{}` already exists, backing up...", dest.display());
                backup_file(ctx, &dest)?;
            }
        }

        if !ctx.dry_run {
            // Using canonicalize ensures the symlink gets an absolute path, preventing broken links
            let abs_src = fs::canonicalize(&path).unwrap_or(path.clone());
            create_symlink(&abs_src, &dest)
                .with_context(|| format!("Failed to symlink {}", path.display()))?;
        }
    }

    Ok(())
}

fn backup_file(ctx: &InstallArgs, path: &Path) -> Result<()> {
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

fn expand_tilde(path: &str) -> Result<PathBuf> {
    let home_dir = std::env::home_dir().with_context(|| "Failed to get home directory")?;
    let expanded = home_dir.join(path.strip_prefix("~/").unwrap_or(path));
    let canonicalized = fs::canonicalize(&expanded)
        .with_context(|| format!("Failed to canonicalize path: {}", expanded.display()))?;
    Ok(canonicalized)
}
