use zed_extension_api as zed;

struct MyExtension {}

impl zed::Extension for MyExtension {
    fn new() -> Self
    where
        Self: Sized,
    {
        Self {}
    }

    fn language_server_command(
        &mut self,
        _server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<zed::Command> {
        let command = worktree
            .which("redscript-ide")
            .ok_or_else(|| "Could not find redscript-ide in the PATH".to_owned())?;
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

zed::register_extension!(MyExtension);
