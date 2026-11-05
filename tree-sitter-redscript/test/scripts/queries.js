// Check CLI captures by source position. The 0.25.10 query --test matcher can
// incorrectly match a capture on an earlier row, so do not use it here.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {spawnSync} = require('node:child_process');

const root = path.resolve(__dirname, '../..');
const result = spawnSync(process.execPath, [
  require.resolve('tree-sitter-cli/cli.js'), 'query', '--captures',
  'queries/highlights.scm', 'test/queries.reds',
], {cwd: root, encoding: 'utf8'});
if (result.error) throw result.error;
if (result.status !== 0) {
  process.stderr.write(result.stderr);
  process.stderr.write(result.stdout);
  process.exit(result.status || 1);
}
const captures = [...result.stdout.matchAll(
  /capture: \d+ - ([\w.]+), start: \((\d+), (\d+)\), end: \((\d+), (\d+)\)/g,
)].map(([, name, row, column, endRow, endColumn]) => ({
  name, row: +row, column: +column, endRow: +endRow, endColumn: +endColumn,
}));
assert(captures.length > 0, 'Expected CLI query captures');

const lines = fs.readFileSync(path.join(root, 'test/queries.reds'), 'utf8').split('\n');
let assertions = 0;
let sourceRow = -1;
for (let row = 0; row < lines.length; row++) {
  const match = /^\s*\/\/\s*\^\s+([\w.]+)\s*$/.exec(lines[row]);
  if (!match) {
    if (lines[row].trim()) sourceRow = row;
    continue;
  }
  const column = lines[row].indexOf('^');
  assert(captures.some(capture => capture.name === match[1]
    && (sourceRow > capture.row || (sourceRow === capture.row && column >= capture.column))
    && (sourceRow < capture.endRow || (sourceRow === capture.endRow && column < capture.endColumn))),
  `Missing ${match[1]} at ${sourceRow + 1}:${column + 1}`);
  assertions++;
}
assert(assertions > 0, 'Expected highlight assertions');
console.log(`Highlights query: ${assertions} assertions passed (${captures.length} captures)`);
