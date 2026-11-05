# Basic REDmod Tree-sitter grammar

A working, syntax-oriented REDmod grammar for editor use. This is **not parser
parity** or a replacement for the compiler's validation.

The grammar is derived from the rules in the sibling `redscript` repository:

- `crates/syntax/redmod/parser/src/parser/native.rs`: declarations and statements
- `crates/syntax/redmod/parser/src/parser/item.rs`: fields and annotations
- `crates/syntax/redmod/parser/src/parser/expr.rs`: expressions and casts
- `crates/syntax/redmod/parser/src/parser.rs`: types
- `crates/syntax/redmod/parser/src/lexer.rs`: literals and comments

## Covered syntax

- Classes, structs, enums, functions, events, operators, and cast declarations;
  declaration qualifiers, metadata, annotations, grouped parameters, `var`/`let`,
  `default`/`hint`, and basic `@module`/`@using` directives.
- Nested generic types (including `array`, `ref`, `wref`, `weak`, `script_ref`,
  `mixedRef`) and fixed array suffixes such as `Int32[4][2]`.
- Assignment and ternary expressions, logical/bitwise/comparison/arithmetic
  precedence, unary expressions, member/index/call chains, omitted argument
  slots, array literals, `new Type`, `Cast<T>(value)`, `(T)value`, and `value as T`.
- Blocks, `if`/`else`, `while`, `do`/`while`, C-style `for` (including empty slots
  and comma sequences), switches with fallthrough labels, and jump statements.
- Raw double-quoted strings, single-quoted and `n"..."` CNames, `R"..."` resource
  references, `T"..."` TweakDB IDs, decimal numbers, booleans, and uppercase `NULL`.
  Backslashes do not escape delimiters, matching the REDmod lexer.
- Line/doc comments and arbitrarily nested block comments via a small stateless
  C scanner. An unfinished block comment is highlighted through EOF while editing.

`queries/highlights.scm` is a minimal query for this grammar's node names. It is
not a drop-in query for the old community grammar. No bindings or runtime npm
packages are generated or required.

## Generate and test

Use Node/npm and a native C/C++ compiler supported by Tree-sitter (on Windows,
for example, the Visual Studio C++ build tools). The CLI is a local development
dependency pinned to **0.25.10**, with an npm lockfile; no global install is needed.
Its installation downloads the platform CLI binary, so network access is needed
for a fresh install. If npm blocks dependency install scripts, review and approve
the `tree-sitter-cli` install script according to your npm version's policy.

From this directory:

```sh
npm ci
npm run generate
npm test
npm run test:queries
```

Generated `src/parser.c`, `src/grammar.json`, `src/node-types.json`, and
`src/tree_sitter/*.h` are checked in. Regenerate them after changing `grammar.js`.
The external `src/scanner.c` is handwritten and must be compiled alongside
`parser.c`. Native compiler output and `node_modules` are ignored.

The corpus checks tree structure, including precedence/associativity,
cast-versus-grouping choices, nested types/comments, and raw literal boundaries.
The query smoke test compiles the highlight query and prints captures for
`test/queries.script`; it does not assert every capture or test Zed rendering.

With the sibling repository available, an additional read-only compatibility
smoke test is:

```sh
node_modules/.bin/tree-sitter parse --quiet --stat --timeout 2000000 ../../redscript/crates/syntax/redmod/parser/tests/data/ast/*.script test/queries.script
```

The eight corpus tests, query smoke test, and all nine upstream AST fixture
files passed locally on Windows. This is a small fixture set, not a full game
source or incremental-edit compatibility test.

## Deliberate limits

- Generic type names/arity, qualifier order/combinations, enum values, array
  sizes, numeric ranges/suffix validity, and module path contents are not
  compiler-validated. In particular, arbitrary generic names, empty array
  literals, and syntactically call-shaped allocations may parse even though the
  native parser rejects them.
- Cast/grouping ambiguity prefers C-style casts for `(T)(x)` and `(T)-x`, as the
  native parser does for those forms. Context-sensitive keyword identifiers and
  every ambiguity/recovery behavior are not guaranteed to match the compiler.
- Brace-delimited control bodies are supported. Optional semicolons after
  control blocks become separate empty statements, rather than being attached
  to the control node as in the compiler AST.
- This is a concrete syntax tree, not the Rust AST: wrappers and omitted
  argument slots differ, documentation comments remain trivia, and no semantic
  checks, diagnostics parity, name resolution, interpolation, or preprocessor
  support are provided. The node schema may evolve before publication.

## Zed integration requires publication

This directory is only a local grammar source and test project. Zed's extension
manifest grammar registration uses a **repository URL, real revision, and optional
subdirectory path**, not a local filesystem path. Before registering this grammar,
publish the generated sources and scanner in an accessible repository, then pin
an actual published commit and its correct subdirectory in `extension.toml`.
No repository URL or revision is invented here.

Until publication, the parent extension can register REDmod using the existing
community grammar as a fallback. That fallback is not this grammar and does not
provide its REDmod-specific coverage. This project does not change the parent
manifest, language registration, or language queries.
