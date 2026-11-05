"""Tests for parsing CLI capture ranges without relying on its display text."""

from pathlib import Path
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
from validate_grammars import captures, require


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


if __name__ == "__main__":
    unittest.main()
