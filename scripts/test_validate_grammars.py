"""Tests for grammar checkouts and parsing CLI capture ranges."""

import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import validate_grammars
from validate_grammars import captures, checkout, require


class CaptureTests(unittest.TestCase):
    def test_byte_columns_multiline_and_crlf(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "sample.reds"
            source.write_bytes('é`x\r\nsecond\r\n'.encode("utf-8"))
            output = (
                "capture: 0 - name, start: (0, 2), end: (0, 4), text: `not authoritative`\n"
                "capture: 1 - function.around, start: (0, 0), end: (1, 6)\n"
                "capture: 2 - name, start: (0, 2), end: (0, 4)\n"
            )
            self.assertEqual(captures(output, source), {
                ("name", "`x"), ("function.around", "é`x\r\nsecond"),
            })

    def test_empty_output_has_no_captures(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "empty.reds"
            source.write_bytes(b"")
            self.assertEqual(captures("warning: no captures", source), set())

    def test_validation_failure_is_not_an_optimizable_assert(self):
        with self.assertRaisesRegex(RuntimeError, "pin mismatch"):
            require(False, "pin mismatch")


class CheckoutTests(unittest.TestCase):
    def check_checkout(self, cached, dirty=False):
        repository = "https://example.com/grammar"
        rev = "a" * 40
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp) / "redmod"
            if cached:
                directory.mkdir()

            def git(*args, **kwargs):
                if "get-url" in args:
                    return repository
                if "diff" in args:
                    return "tracked changes" if dirty else ""
                if "rev-parse" in args:
                    return rev
                if "checkout" in args:
                    (directory / "src").mkdir(parents=True)
                    for path, data in {
                        "tree-sitter.json": {"grammars": [{"name": "redmod", "path": "."}]},
                        "src/grammar.json": {"name": "redmod"},
                        "package.json": {"devDependencies": {
                            "tree-sitter-cli": validate_grammars.CLI_VERSION}},
                        "src/node-types.json": [],
                    }.items():
                        (directory / path).write_text(json.dumps(data), encoding="utf-8")
                    for path in ("src/parser.c", "src/scanner.c"):
                        (directory / path).write_text(
                            "tree_sitter_redmod_external_scanner_scan", encoding="utf-8")
                return ""

            with patch.object(validate_grammars, "WORK", Path(temp)), \
                    patch.object(validate_grammars, "run", side_effect=git) as run:
                pin = {"repository": repository, "rev": rev}
                if dirty:
                    with self.assertRaisesRegex(RuntimeError, "cached checkout has tracked changes"):
                        checkout("redmod", pin)
                else:
                    self.assertEqual(checkout("redmod", pin),
                                     (directory, {"name": "redmod", "path": "."}))
                commands = [call.args for call in run.call_args_list]
                self.assertEqual(any("clone" in args for args in commands), not cached)
                self.assertEqual(any("diff" in args for args in commands), cached)
                self.assertEqual(any("checkout" in args for args in commands), not dirty)
                if dirty:
                    self.assertFalse(any("fetch" in args for args in commands))

    def test_fresh_clone_skips_dirty_check(self):
        self.check_checkout(cached=False)

    def test_clean_cached_checkout_is_reused(self):
        self.check_checkout(cached=True)

    def test_dirty_cached_checkout_is_rejected(self):
        self.check_checkout(cached=True, dirty=True)


if __name__ == "__main__":
    unittest.main()
