; Base identifier rule
(identifier) @variable

; Keywords
[
  "func"
  "class"
  "struct"
  "enum"
  "let"
  "import"
  "module"
  "extends"
  "as"
] @keyword

[
  "if"
  "else"
  "switch"
  "case"
  "default"
  "while"
  "for"
  "in"
  "break"
  "continue"
  "return"
] @keyword

; Modifiers and visibility
(visibility) @keyword
(item_qualifier) @keyword

; Constants and built-ins
[
  "true"
  "false"
] @boolean

"null" @constant

[
  "this"
  "super"
] @variable.special

; Annotations
(annotation
  "@" @punctuation.special
  name: (identifier) @function.macro)

(annotation
  "(" @punctuation.bracket
  (_) @type
  ")" @punctuation.bracket)

; Types and declarations
(class_declaration
  name: (identifier) @type)
(enum_declaration
  name: (identifier) @type)
(type
  (named_type
    name: (identifier) @type))

; Enum entries
(enum_entry
  name: (identifier) @enum)

; Functions and methods
(function_declaration
    name: (identifier) @function)

(item_qualifier
  "native" @keyword)

; Member access
(member_expression
  member: (identifier) @property)

; Method calls
(call_expression
  function: (expression
    (member_expression
      member: (identifier) @function.method)))

; Function calls
(call_expression
  function: (expression
    (primary_expression
      (identifier) @function)))

; Parameters
(parameter
  name: (identifier) @variable)

; Module and imports
(module_declaration
  (module_path
    (identifier) @namespace))
(import_declaration "import" @keyword)

; Operators
[
  "+"
  "-"
  "*"
  "/"
  "%"
  "=="
  "!="
  "<"
  "<="
  ">"
  ">="
  "&&"
  "||"
  "&"
  "|"
  "^"
  "!"
  "~"
  "+="
  "-="
  "*="
  "/="
  "|="
  "&="
  "?"
] @operator

; Punctuation
[ "." ";" ":" "," "->" ] @punctuation.delimiter
[ "(" ")" "[" "]" "{" "}" ] @punctuation.bracket

; Comments
(line_comment) @comment
(block_comment) @comment
(doc_comment) @comment.doc

; Strings and literals
(string) @string
(string_content) @string
(interpolated_string) @string
(escape_sequence) @string.escape
(cname) @string.special
(resref) @string.special
(tdbid) @string.special

; Numbers
(number) @number

; Array literals
(array_literal) @punctuation.bracket
