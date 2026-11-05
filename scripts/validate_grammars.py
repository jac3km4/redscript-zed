#!/usr/bin/env python3
"""Validate the manifest's remote parsers and extension-owned queries (Python 3.11+)."""

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / "target" / "ci-grammars"
CLI_VERSION = "0.25.10"

# Exact capture/text pairs, not just successful query compilation or nonempty output.
EXPECT = {
    "redscript": {
        "brackets.scm": [("open", "<"), ("close", ">"), ("open", "\\("), ("close", ")")],
        "highlights.scm": [("type", "Demo"), ("function", "Run"), ("function", "Ping"),
                           ("variable.parameter", "name"), ("comment.doc", "/// Documentation for Demo"),
                           ("comment", "/* outer /* nested */ comment */")],
        "indents.scm": [("indent", "<T>"), ("outdent", "}")],
        "injections.scm": [("injection.content", "/// Documentation for Demo")],
        "locals.scm": [("local.definition", "label"), ("local.reference", "label")],
        "outline.scm": [("name", "Demo"), ("name", "Run"), ("name", "Top")],
        "tags.scm": [("name", "Ping"), ("definition.function", "func Top() {}")],
        "textobjects.scm": [("function.around", "func Top() {}"),
                            ("comment.around", "/* outer /* nested */ comment */")],
    },
    "redmod": {
        "highlights.scm": [("type", "Demo"), ("function", "Run"), ("function", "Ping"),
                           ("variable.parameter", "index"), ("property", "module"),
                           ("string", "'Ready'"), ("constant.builtin", "NULL"),
                           ("comment", "/* outer /* nested */ comment */")],
    },
}


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def run(*args, cwd=ROOT, capture=False):
    args = [str(arg) for arg in args]
    print("+ " + subprocess.list2cmdline(args), flush=True)
    result = subprocess.run(args, cwd=cwd, check=True, text=True, encoding="utf-8",
                            stdout=subprocess.PIPE if capture else None,
                            stderr=subprocess.STDOUT if capture else None)
    return result.stdout or ""


def read_toml(path):
    return tomllib.loads(path.read_text(encoding="utf-8"))


def checkout(name, pin):
    repository, rev = pin["repository"], pin["rev"]
    require(re.fullmatch(r"[0-9a-f]{40}", rev), f"{name}: rev must be a full commit SHA")
    require(repository.startswith("https://"), f"{name}: expected HTTPS repository")
    require("path" not in pin, f"{name}: validator expects a repository-root parser")
    directory = WORK / name
    cached = directory.exists()
    if not cached:
        run("git", "clone", "--no-checkout", repository, directory)
    require(run("git", "-C", directory, "remote", "get-url", "origin", capture=True).strip()
            == repository, f"{name}: cached repository URL differs; remove {directory}")
    if cached:
        require(not run("git", "--no-pager", "-C", directory, "diff", "HEAD", "--",
                        capture=True).strip(), f"{name}: cached checkout has tracked changes")
    run("git", "-C", directory, "fetch", "--depth=1", "origin", rev)
    run("git", "-C", directory, "checkout", "--detach", rev)
    require(run("git", "-C", directory, "rev-parse", "HEAD", capture=True).strip() == rev,
            f"{name}: checkout does not match manifest pin")
    metadata = json.loads((directory / "tree-sitter.json").read_text(encoding="utf-8"))
    grammars = [grammar for grammar in metadata["grammars"] if grammar["name"] == name]
    require(len(grammars) == 1 and grammars[0]["path"] == ".",
            f"{name}: remote grammar name/path mismatch")
    generated = json.loads((directory / "src/grammar.json").read_text(encoding="utf-8"))
    require(generated["name"] == name, f"{name}: generated grammar name mismatch")
    package = json.loads((directory / "package.json").read_text(encoding="utf-8"))
    require(package["devDependencies"]["tree-sitter-cli"] == CLI_VERSION,
            f"{name}: remote CLI version differs from validator")
    for source in ("src/parser.c", "src/scanner.c", "src/node-types.json"):
        require((directory / source).is_file(), f"{name}: missing {source}")
    parser = (directory / "src/parser.c").read_text(encoding="utf-8")
    scanner = (directory / "src/scanner.c").read_text(encoding="utf-8")
    require(f"tree_sitter_{name}_external_scanner_scan" in parser
            and f"tree_sitter_{name}_external_scanner_scan" in scanner,
            f"{name}: parser/scanner symbol mismatch")
    return directory, grammars[0]


def captures(output, source):
    # CLI 0.25.10 reports UTF-8 byte columns. Slice source rather than its formatted
    # text output so multiline captures and backticks are handled unambiguously.
    lines = source.read_bytes().splitlines(keepends=True)
    offsets = [0]
    for line in lines:
        offsets.append(offsets[-1] + len(line))
    data = b"".join(lines)
    result = set()
    pattern = r"capture: \d+ - ([\w.]+), start: \((\d+), (\d+)\), end: \((\d+), (\d+)\)"
    for match in re.finditer(pattern, output):
        capture, row, col, end_row, end_col = match.groups()
        text = data[offsets[int(row)] + int(col):offsets[int(end_row)] + int(end_col)]
        result.add((capture, text.decode("utf-8")))
    return result


def validate(cli, wasm):
    version = run(cli, "--version", capture=True).strip()
    require(version.split()[:2] == ["tree-sitter", CLI_VERSION],
            f"expected tree-sitter {CLI_VERSION}, got {version}")
    manifest = read_toml(ROOT / "extension.toml")
    configs = sorted((ROOT / "languages").glob("*/config.toml"))
    languages = [read_toml(path) for path in configs]
    require({config["grammar"] for config in languages} == set(manifest["grammars"]),
            "language configurations and grammar pins differ")
    require({config["name"] for config in languages}
            == set(manifest["language_servers"]["redscript-ide"]["languages"]),
            "language-server registration differs from language configurations")
    all_queries = set((ROOT / "languages").rglob("*.scm"))
    checked = set()
    for config_path, config in zip(configs, languages):
        name = config["grammar"]
        directory, metadata = checkout(name, manifest["grammars"][name])
        require(set(config["path_suffixes"]) == set(metadata["file-types"]),
                f"{name}: remote and extension file types differ")
        require(manifest["language_servers"]["redscript-ide"]["language_ids"][config["name"]]
                == name, f"{name}: language-server ID mismatch")
        fixture = ROOT / "scripts" / "fixtures" / f"{name}.{config['path_suffixes'][0]}"
        queries = sorted(config_path.parent.rglob("*.scm"))
        require({query.name for query in queries} == set(EXPECT[name]),
                f"{name}: add explicit capture expectations for every query")
        # The CLI compiles both parser.c and scanner.c. Corpus tests also exercise
        # scanner state/serialization beyond the extension's small smoke fixtures.
        run(cli, "build", directory, cwd=directory)
        run(cli, "test", cwd=directory)
        run(cli, "parse", "--quiet", fixture, cwd=directory)
        for query in queries:
            output = run(cli, "query", "--captures", query, fixture, cwd=directory, capture=True)
            actual = captures(output, fixture)
            for expected in EXPECT[name][query.name]:
                require(expected in actual, f"{query}: missing capture {expected!r}\n{output}")
            if query.name == "injections.scm":
                require({text for capture, text in actual if capture == "injection.content"}
                        == {"/// Documentation for Demo"},
                        "non-doc comments must not be injected as Markdown")
            checked.add(query)
            print(f"Validated {query.relative_to(ROOT)} ({len(actual)} capture/text pairs)")
        if wasm:
            artifact = WORK / f"{name}.wasm"
            run(cli, "build", "--wasm", "--output", artifact, directory, cwd=directory)
            require(artifact.read_bytes()[:8] == b"\x00asm\x01\x00\x00\x00",
                    f"{name}: invalid WASM artifact")
            run(cli, "test", "--wasm", cwd=directory)
            run(cli, "parse", "--wasm", "--quiet", fixture, cwd=directory)
    require(checked == all_queries, f"unchecked queries: {all_queries - checked}")
    print(f"Validated {len(checked)} queries against pinned remote grammars.")
    print("Parser WASM builds and execution passed." if wasm else "Parser WASM validation NOT run (use --wasm).")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tree-sitter", type=Path, help="existing CLI 0.25.10 (otherwise install in a temporary npm prefix)")
    parser.add_argument("--wasm", action="store_true", help="also build and exercise WASM parsers; requires emcc")
    args = parser.parse_args()
    WORK.mkdir(parents=True, exist_ok=True)
    if args.wasm:
        require(shutil.which("emcc"), "--wasm requires Emscripten's emcc on PATH")
    if args.tree_sitter:
        validate(args.tree_sitter.resolve(), args.wasm)
    else:
        with tempfile.TemporaryDirectory(prefix="redscript-tree-sitter-") as temp:
            npm = shutil.which("npm.cmd" if os.name == "nt" else "npm")
            require(npm, "Node.js/npm is required to install the pinned CLI")
            run(npm, "install", "--prefix", temp, "--no-audit", "--no-fund", "--package-lock=false",
                f"tree-sitter-cli@{CLI_VERSION}")
            executable = "tree-sitter.cmd" if os.name == "nt" else "tree-sitter"
            validate(Path(temp) / "node_modules" / ".bin" / executable, args.wasm)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Validation failed: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stdout:
            print(error.stdout, file=sys.stderr)
        sys.exit(1)
