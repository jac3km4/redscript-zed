use std::fs;

use zed_extension_api::{self as zed, settings::LspSettings, LanguageServerId, Worktree};

struct RedscriptExtension {
    cached_lsp_path: Option<String>,
}

const GITHUB_REPO: &str = "jac3km4/redscript-ide";

impl RedscriptExtension {
    fn get_lsp_path(
        &mut self,
        lsp_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> zed::Result<String> {
        let lsp = lsp_id.as_ref();

        if let Some(path) = LspSettings::for_worktree(lsp, worktree)
            .ok()
            .and_then(|settings| settings.binary)
            .and_then(|settings| settings.path)
        {
            return Ok(path);
        }

        if let Some(path) = worktree.which(lsp) {
            return Ok(path);
        }

        if let Some(path) = &self.cached_lsp_path {
            if fs::metadata(path).map_or(false, |stat| stat.is_file()) {
                return Ok(path.to_string());
            }
        }

        zed::set_language_server_installation_status(
            &lsp_id,
            &zed::LanguageServerInstallationStatus::CheckingForUpdate,
        );

        let release = zed::latest_github_release(
            GITHUB_REPO,
            zed::GithubReleaseOptions {
                require_assets: true,
                pre_release: false,
            },
        )?;

        let (plat, arch) = zed::current_platform();

        let release_filename: &str = match arch {
            zed::Architecture::Aarch64 => match plat {
                zed::Os::Mac => "redscript-ide-aarch64-apple-darwin",
                _ => {
                    return Err(format!(
                        "{:?} arch is not supported for platform {:?}",
                        arch, plat
                    ))
                }
            },
            zed::Architecture::X8664 => match plat {
                zed::Os::Linux => "redscript-ide-x86_64-unknown-linux-gnu",
                zed::Os::Mac => "redscript-ide-x86_64-apple-darwin",
                zed::Os::Windows => "redscript-ide",
            },
            _ => {
                return Err(format!(
                    "{:?} arch is not supported for platform {:?}",
                    arch, plat
                ))
            }
        };

        // Hacky way to add .exe extension
        let asset_name = format!(
            "{release_filename}{}",
            match plat {
                zed::Os::Windows => ".exe",
                _ => "",
            }
        );

        let asset = release
            .assets
            .iter()
            .find(|asset| asset.name == asset_name)
            .ok_or_else(|| format!("Release artifact {} not found!", asset_name))?;

        let filename = format!(
            "{}_{}{}",
            release_filename,
            release.version,
            match plat {
                zed::Os::Windows => ".exe",
                _ => "",
            }
        );

        if !fs::metadata(&filename).map_or(false, |stat| stat.is_file()) {
            zed::set_language_server_installation_status(
                &lsp_id,
                &zed::LanguageServerInstallationStatus::CheckingForUpdate,
            );

            install_download(std::path::Path::new(&filename), |temporary| {
                let temporary = temporary
                    .to_str()
                    .ok_or_else(|| "Invalid download path".to_owned())?;
                zed::download_file(
                    &asset.download_url,
                    temporary,
                    zed::DownloadedFileType::Uncompressed,
                )
                .map_err(|e| format!("Failed to download release {}: {}", release.version, e))?;
                zed::make_file_executable(temporary)
            })?;

            // Clean up old LSP versions
            let entries =
                fs::read_dir(".").map_err(|e| format!("Failed to list working directory: {e}"))?;
            for entry in entries {
                let entry = entry.map_err(|e| format!("Failed to load directory entry: {e}"))?;
                if entry.file_type().is_ok_and(|kind| kind.is_file())
                    && entry
                        .file_name()
                        .to_str()
                        .is_some_and(|name| name != filename && owned_release_file(name))
                {
                    fs::remove_file(entry.path()).ok();
                }
            }
        }

        self.cached_lsp_path = Some(filename.clone());

        return Ok(filename);
    }
}

impl zed::Extension for RedscriptExtension {
    fn new() -> Self
    where
        Self: Sized,
    {
        Self {
            cached_lsp_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        _server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<zed::Command> {
        let command = self.get_lsp_path(_server_id, worktree).or_else(|e| {
            Err(format!(
                "Failed to obtain language server path for redscript-ide: {e}"
            ))
        })?;

        Ok(zed::Command {
            command,
            args: vec![],
            env: Default::default(),
        })
    }

    fn language_server_initialization_options(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<Option<zed::serde_json::Value>> {
        let settings = zed::settings::LspSettings::for_worktree("redscript-ide", worktree)?;
        Ok(settings.initialization_options)
    }
}

fn install_download(
    destination: &std::path::Path,
    download: impl FnOnce(&std::path::Path) -> zed::Result<()>,
) -> zed::Result<()> {
    let temporary = destination.with_extension("download");
    let result = download(&temporary).and_then(|()| {
        fs::rename(&temporary, destination)
            .map_err(|e| format!("Failed to install {}: {e}", destination.display()))
    });
    if result.is_err() {
        let _ = fs::remove_file(&temporary);
    }
    result
}

fn owned_release_file(name: &str) -> bool {
    let Some(version) = [
        "redscript-ide_",
        "redscript-ide-x86_64-unknown-linux-gnu_",
        "redscript-ide-x86_64-apple-darwin_",
        "redscript-ide-aarch64-apple-darwin_",
    ]
    .iter()
    .find_map(|prefix| name.strip_prefix(prefix)) else {
        return false;
    };
    let version = version.strip_suffix(".exe").unwrap_or(version);
    let version = version.strip_prefix('v').unwrap_or(version);
    let core = version.split(['-', '+']).next().unwrap_or_default();
    let mut parts = core.split('.');
    (0..3).all(|_| {
        parts
            .next()
            .is_some_and(|part| !part.is_empty() && part.bytes().all(|c| c.is_ascii_digit()))
    }) && parts.next().is_none()
        && version
            .bytes()
            .all(|c| c.is_ascii_alphanumeric() || matches!(c, b'.' | b'-' | b'+'))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cleanup_only_matches_owned_release_binaries() {
        for name in [
            "redscript-ide_v0.2.25.exe",
            "redscript-ide-x86_64-unknown-linux-gnu_0.2.25",
            "redscript-ide-aarch64-apple-darwin_v1.0.0-preview.1",
        ] {
            assert!(owned_release_file(name), "{name}");
        }
        for name in [
            "extension.wasm",
            "settings.json",
            "redscript-ide_notes.txt",
            "redscript-ide_v1.0.0.exe.download",
            "other_v1.0.0.exe",
        ] {
            assert!(!owned_release_file(name), "{name}");
        }
    }

    #[test]
    fn downloads_are_only_published_after_success() {
        let root = std::env::temp_dir().join(format!("redscript-download-{}", std::process::id()));
        fs::create_dir_all(&root).unwrap();
        let destination = root.join("server.exe");
        let _ = fs::remove_file(&destination);
        let failed = install_download(&destination, |temporary| {
            fs::write(temporary, "partial").unwrap();
            assert!(!destination.exists());
            Err("interrupted".into())
        });
        assert!(failed.is_err());
        assert!(!destination.exists());
        assert!(!destination.with_extension("download").exists());
        install_download(&destination, |temporary| {
            fs::write(temporary, "complete").unwrap();
            assert!(!destination.exists());
            Ok(())
        })
        .unwrap();
        assert_eq!(fs::read_to_string(&destination).unwrap(), "complete");
        fs::remove_dir_all(root).unwrap();
    }
}

zed::register_extension!(RedscriptExtension);
