(identifier) @variable
(line_comment) @comment
(block_comment) @comment

["module" "import"] @keyword.import
["class" "struct" "enum" "extends" "func" "let" "const" "new" "as"
 "explicit" "implicit" "operator"] @keyword
["if" "else" "switch" "case" "default"] @keyword.conditional
["while" "for" "in" "break" "continue"] @keyword.repeat
"return" @keyword.return
(visibility) @keyword.modifier
(qualifier) @keyword.modifier
(parameter_qualifier) @keyword.modifier

(integer_literal) @number
(float_literal) @number
(boolean_literal) @boolean
(null_literal) @constant.builtin
(this_expression) @variable.builtin
(super_expression) @variable.builtin
(string_literal) @string
(cname_literal) @string.special
(resource_literal) @string.special
(tweakdbid_literal) @string.special
(interpolated_string ["s\"" "\""] @string)
(interpolated_string (string_content) @string)
(escape_sequence) @string.escape
(interpolation ["\\(" ")"] @punctuation.special)

(class_declaration name: (identifier) @type)
(struct_declaration name: (identifier) @type)
(enum_declaration name: (identifier) @type)
(named_type name: (identifier) @type)
(type_parameter name: (identifier) @type.parameter)
(aggregate_pattern name: (identifier) @type)
(enum_variant name: (identifier) @constant)
(function_declaration name: (identifier) @function)
(operator_name) @function
(member_expression member: (identifier) @property)
(call_expression function: (expression (identifier) @function.call))
(call_expression function: (expression (member_expression member: (identifier) @function.method.call)))
(field_declaration name: (identifier) @property)
(default_declaration target: (identifier) @property)
(field_pattern name: (identifier) @property)
(parameter name: (identifier) @variable.parameter)
(lambda_parameter name: (identifier) @variable.parameter)
(annotation name: (identifier) @attribute)
(path (identifier) @module)

["=" "+=" "-=" "*=" "/=" "|=" "&=" "+" "-" "*" "/" "%"
 "==" "!=" "<" "<=" ">" ">=" "&&" "||" "&" "|" "^" "!" "~"
 "?" "->"] @operator
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["." "," ":" ";"] @punctuation.delimiter
"@" @punctuation.special
