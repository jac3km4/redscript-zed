# redscript-zed

Zed extension for REDscript.

## installation

- Install the `REDscript` extension from the marketplace.
- Configure the required `lsp.redscript-ide.initialization_options.game_dir` setting in Zed's `settings.json`:
  ```json
    "lsp": {
      "redscript-ide": {
        "initialization_options": {
          "game_dir": "D:\\Games\\Cyberpunk 2077"
        }
      }
    }
  ```
- The extension will prioritize the LSP found in PATH or extension LSP settings.
- If neither are present, the extension will automatically download the latest LSP version from https://github.com/jac3km4/redscript-ide.
