# redscript-zed

Zed extension for community REDscript (`.reds`) and REDmod (`.script`). Both
languages use `redscript-ide`; the server chooses the dialect by extension.

## installation

- Install the `REDscript` extension from the marketplace.
- Configure `lsp.redscript-ide.initialization_options.game_dir` in Zed's `settings.json`
  to load engine symbols (or supply `script_cache_path` instead):
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

## REDmod support

Use a `redscript-ide` build containing REDmod support. Until that build is released,
configure a local executable through Zed's `lsp.redscript-ide.binary.path` setting.
Initialization options are forwarded unchanged, including `script_cache_path`.

Opening a `.script` file selects **REDmod** and starts the same language server as
`.reds`. Diagnostics, navigation, completion, and formatting are provided by the
server's supported REDmod subset, not full official-compiler parity.

## Syntax grammars

Custom grammars are maintained and tested in separate repositories:

- [`tree-sitter-reds`](https://github.com/jac3km4/tree-sitter-reds): community
  declarations, generics, lambdas, escaped literals, interpolation, and nested comments.
- [`tree-sitter-redmod`](https://github.com/jac3km4/tree-sitter-redmod): native
  declarations, directives, C-style control flow, raw literals, and nested comments.

Zed fetches the generated parsers directly from the immutable revisions pinned in
`extension.toml`. No submodules or local grammar checkouts are required. This
extension owns the language configurations and Zed-specific queries in `languages/`.

For grammar development, clone the relevant repository separately, run its tests,
and commit and push the parser changes there. Then update the matching `rev` in
`extension.toml` to the published commit and adapt the language queries if the node
schema changed. The parsers live at their repository roots; no manifest `path`
setting is needed. Rebuild/reinstall the extension after changing the pins.
Grammar tests cover syntax, not complete compiler validation or interactive Zed
rendering.
