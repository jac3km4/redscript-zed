; General rules precede the more specific identifier roles below.
(identifier) @variable
(line_comment) @comment
(block_comment) @comment
((line_comment) @comment.doc
  (#match? @comment.doc "^///([^/]|$)"))

["module" "import" "class" "struct" "enum" "extends" "func" "let" "const"
 "new" "as" "explicit" "implicit" "operator" "if" "else" "switch" "case"
 "default" "while" "for" "in" "break" "continue" "return"] @keyword
(visibility) @keyword
(qualifier) @keyword
(parameter_qualifier) @keyword

(integer_literal) @number
(float_literal) @number
(boolean_literal) @boolean
(null_literal) @constant.builtin
(this_expression) @variable.special
(super_expression) @variable.special
(string_literal) @string
(cname_literal) @string.special
(resource_literal) @string.special
(tweakdbid_literal) @string.special
; Do not capture the entire interpolated string: expressions are ordinary code.
(interpolated_string ["s\"" "\""] @string)
(interpolated_string (string_content) @string)
(escape_sequence) @string.escape
(interpolation ["\\(" ")"] @punctuation.special)

(class_declaration name: (identifier) @type)
(struct_declaration name: (identifier) @type)
(enum_declaration name: (identifier) @type)
(named_type name: (identifier) @type)
(type_parameter name: (identifier) @type)
(aggregate_pattern name: (identifier) @type)
(enum_variant name: (identifier) @enum)
(function_declaration name: (identifier) @function)
(operator_name) @function
(member_expression member: (identifier) @property)
(call_expression function: (expression (identifier) @function))
(call_expression function: (expression (member_expression member: (identifier) @function)))
(field_declaration name: (identifier) @property)
(default_declaration target: (identifier) @property)
(field_pattern name: (identifier) @property)
(parameter name: (identifier) @variable.parameter)
(lambda_parameter name: (identifier) @variable.parameter)
(annotation name: (identifier) @attribute)
(path (identifier) @type)

["=" "+=" "-=" "*=" "/=" "|=" "&=" "+" "-" "*" "/" "%"
 "==" "!=" "<" "<=" ">" ">=" "&&" "||" "&" "|" "^" "!" "~"
 "?" "->"] @operator
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["." "," ":" ";"] @punctuation.delimiter
"@" @punctuation.special
