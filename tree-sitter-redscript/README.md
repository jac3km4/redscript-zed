# tree-sitter-redscript

A basic Tree-sitter grammar for **community REDscript** (`.reds`), derived from
`redscript/crates/syntax/community/parser/src/lexer.rs`, `parser.rs`, and
`parser/{item,stmt,expr}.rs`. Binary precedence follows the community AST's
`BinOp::precedence`. This is a new local grammar, not a dependency on or a
fork of the old `jac3km4/tree-sitter-redscript` grammar.

The sibling `tree-sitter-redmod` supplied the package layout and the starting
nested-comment scanner. REDmod's `function`/`var` declarations, directives,
raw strings, C-style loops, and uppercase `NULL` literal are not community
syntax. `NULL` can still parse as an ordinary identifier, not a null literal.

## Supported syntax

- Optional `module` path; exact, wildcard, and selected `import`s.
- Annotations, visibility, community item and parameter qualifiers, classes,
  structs, enums, typed fields, and field `default` directives.
- `func`, declaration-only, inline and block bodies, conversion modifiers,
  `operator[]`, generic variance and `extends` bounds, and const return types.
- Named/generic types, `[T]`, `[T; size]`, and `(T, U) -> R` function types.
- `let` and `const` locals, arrays, `new T(...)`, typed/untyped lambdas,
  generic calls, omitted call arguments, member/index access, `as` casts,
  unary/binary operators, right-associative assignments and conditionals.
- `if`/`else`, `while`, `for name in expression`, ordered switch sections,
  returns, breaks, and continues. Conditions and switch cases support `let`
  patterns, including aggregates, arrays with end spreads, `as`, and `?`.
- Decimal literals with `u`, `l`, `ul`, and `d` suffixes; booleans and `null`.
- Escaped strings, `n"..."`, `r"..."`, `t"..."`, and `s"...\(expression)"`
  interpolation (including nested interpolated strings). Supported escapes
  are `\n`, `\r`, `\t`, `\'`, `\"`, `\\`, and `\u{HEX}`.
- Line/doc comments and nested block comments. The external scanner preserves
  whitespace and comment markers inside strings as content.

## Build and test

Node/npm and a native C compiler supported by the Tree-sitter CLI are required.
The CLI is pinned to **0.25.10** in `package.json` and `package-lock.json`.

```sh
npm ci
npm run generate
npm test
npm run test:fixtures
npm run test:queries
```

On npm versions that require explicit install-script approval, allow the
`tree-sitter-cli` install script; it installs the CLI executable.

Generated `src/parser.c`, `src/grammar.json`, `src/node-types.json`, and
`src/tree_sitter/*.h` are checked in. `src/scanner.c` is handwritten and must
be compiled alongside the generated parser. Generation uses ABI 15.

The corpus has 16 cases covering syntax, tree shape/precedence, editing
behavior, and rejection of several non-community forms. The six files in
`test/fixtures/community-formatter/` are copied unchanged from
`redscript/crates/syntax/community/formatter/tests/data/`. The fixture command
parses those six files plus `test/queries.reds` and fails on parse errors.
The highlights command compiles `queries/highlights.scm` and checks 12 capture
positions via a small Node script. It avoids the CLI 0.25.10 `query --test`
matcher, which can incorrectly select a capture from an earlier line.

The CLI may warn that no global parser directories are configured. These
commands use the grammar in the current directory and do not require changing
user-wide configuration.

## Scope and limitations

This is a working syntax/highlighting baseline, **not full compiler parity**.
The community compiler remains authoritative for validation and diagnostics.
For example, this grammar does not check numeric overflow, Unicode scalar
validity, enum/storage compatibility, duplicate switch defaults, qualifier
legality, binding/type rules, or other semantic restrictions. Some contextual
keyword-as-identifier cases can differ from the compiler. Static-array sizes
and enum initializers currently share the general integer token, so their
suffix restrictions are not enforced. Unsuffixed exponent-only numbers are
not supported (the community lexer currently diagnoses them as invalid Int32
literals). Unfinished block comments are deliberately accepted through EOF
for editor highlighting. Generic calls are preferred over comparisons when
both interpretations are possible, as in `Call<T>(value)`.

`queries/highlights.scm` is grammar-local. The parent extension's community
language queries have also been migrated to this node schema; the grammar-local
query test does not exercise every parent query or live Zed behavior.

## Publishing and Zed pinning

The parent extension no longer registers the old external grammar. Before enabling
this parser, publish the grammar (including generated sources and scanner), then
register the **actual published commit SHA** and appropriate subdirectory path in
`extension.toml`. Restore `grammar = "redscript"` in the language config and rebuild
the extension. See the parent README for the manifest example. Until then, the
language has LSP support but no Tree-sitter features. Do not use an invented
revision or retain an old repository's revision for this unrelated grammar.
