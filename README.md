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
- Ensure that you downloaded the `redscript-ide` executable and it is in your PATH.
  - You can set it by searching for 'Edit the system environment variables' on Windows, clicking on 'Environment Variables', and adding the path to the `redscript-ide` executable to the `Path` variable.
