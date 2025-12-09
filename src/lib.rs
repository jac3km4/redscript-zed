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

            zed::download_file(
                &asset.download_url,
                &filename,
                zed::DownloadedFileType::Uncompressed,
            )
            .map_err(|e| format!("Failed to download release {}: {}", release.version, e))?;

            zed::make_file_executable(&filename)?;

            // Clean up old LSP versions
            let entries =
                fs::read_dir(".").map_err(|e| format!("Failed to list working directory: {e}"))?;
            for entry in entries {
                let entry = entry.map_err(|e| format!("Failed to load directory entry: {e}"))?;
                if entry.file_name().to_str() != Some(&filename) {
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
        let options = settings
            .initialization_options
            .ok_or_else(|| "Could not find initialization options for redscript-ide".to_owned())?;
        let game_dir = options.get("game_dir").ok_or_else(|| {
            "Could not find game_dir for redscript-ide in the settings".to_owned()
        })?;
        Ok(Some(zed::serde_json::json!({
            "game_dir": game_dir
        })))
    }
}

zed::register_extension!(RedscriptExtension);
