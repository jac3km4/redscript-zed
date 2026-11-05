# Contributing

## Extension checks

Use a stable Rust toolchain with `rustfmt`, `clippy`, and the Zed component target:

```sh
rustup component add rustfmt clippy
rustup target add wasm32-wasip2
cargo fmt --all -- --check
cargo check --locked --all-targets
cargo clippy --locked --all-targets -- -D warnings
cargo test --locked --all-targets
cargo build --locked --release --target wasm32-wasip2
```

The last command is an actual release component build, not a host-only check.
Its output is `target/wasm32-wasip2/release/redscript_zed.wasm`. It requires the
extension's WASI-compatible API dependency (the `zed_extension_api` 0.7 upgrade);
CI does not rewrite Cargo metadata or update the lockfile. Keep dependency/API
changes and their lockfile update together. CI uses Rust stable rather than
pinning Rust, so compiler updates can introduce new warnings.

## Remote grammar and query validation

Requirements: Python 3.11+ (`tomllib`), Git, Node.js/npm (CI uses Node 22), and a
native C compiler (Clang works on Windows). From the repository root:

```sh
python -B -m unittest discover -s scripts -p 'test_*.py' -v
python scripts/validate_grammars.py
```

The validator installs exactly `tree-sitter-cli@0.25.10` into a temporary npm
prefix, then removes the tooling when finished. npm and the CLI installer need
network access to npm/GitHub. Grammar checkouts and build outputs stay under
`target/ci-grammars/`, never a local `grammars/` directory or a submodule.
To use an existing CLI instead (it must report version 0.25.10):

```sh
python scripts/validate_grammars.py --tree-sitter /absolute/path/to/tree-sitter
```

On Windows, `--tree-sitter` also accepts the npm `tree-sitter.cmd` wrapper. An
existing development backup can be used, for example:

```sh
python scripts/validate_grammars.py --tree-sitter target/grammar-pre-submodule-backup/tree-sitter-redscript/node_modules/.bin/tree-sitter.cmd
```

For each grammar, validation:

- Reads `extension.toml`, fetches its exact full commit SHA over HTTPS, and checks
  the checkout's origin and HEAD. Existing tracked checkout edits cause failure;
  remove the relevant `target/ci-grammars/<name>` to discard an obsolete cache.
- Checks grammar names, root paths, generated metadata, file suffixes, language
  server registrations/IDs, upstream CLI versions, and external scanner symbols.
- Builds the committed generated native parser **with `src/scanner.c`**, runs the
  pinned upstream corpus, and rejects parse errors in extension-owned fixtures.
- Compiles **every** `languages/**/*.scm` against its corresponding remote parser,
  including REDmod highlights, and asserts exact capture/text pairs for every
  query. New queries require explicit expectations in `scripts/validate_grammars.py`.
  Fixtures exercise declarations, calls, doc-comment predicates, nested block
  comments, interpolation, brackets, outlines, locals, tags, and text objects.

To also validate parser WASM, install/activate Emscripten **4.0.10** and put `emcc`
on PATH, then run:

```sh
python scripts/validate_grammars.py --wasm
```

CI installs the official emsdk at commit
`62a853cd3b3134398ce85cde8bb5cbb2ef0194cb` (tag `4.0.10`) and activates SDK 4.0.10.
The CLI's `build --wasm` compiles the committed parser and external scanner,
checks the resulting `target/ci-grammars/{redscript,redmod}.wasm` headers, and then
runs upstream corpus tests and parses the extension fixtures through the CLI's
WASM runtime. The extension's Rust WASI component and these Tree-sitter parser
WASM modules are separate artifacts; neither build substitutes for the other.

## Updating grammar pins and limitations

Publish grammar changes in the upstream repository first, then update `rev` in
`extension.toml` to the full published commit. Adapt the extension queries and
fixtures/expectations when the node schema changes. Validation never regenerates
parsers, substitutes local backup grammars, or updates pins automatically.

Native-only validation explicitly reports that WASM was not run. A missing
Emscripten installation is a hard failure with `--wasm`, not a silent skip. These
checks validate parser/query compatibility and selected capture behavior, not
every possible match or predicate/directive implementation in Zed. They do not
test interactive rendering, installation, LSP downloads, game symbols, or full
compiler parity. Before release, install the extension in Zed and smoke-test both
`.reds` and `.script` files, highlighting, navigation, and language-server startup.
