(identifier) @variable
(type name: (identifier) @type)
(class_declaration name: (identifier) @type)
(struct_declaration name: (identifier) @type)
(enum_declaration name: (identifier) @type)
(enum_variant name: (identifier) @constant)
(function_declaration name: (identifier) @function)
(call_expression function: (expression (identifier) @function))
(member_expression member: (identifier) @property)
(parameter name: (identifier) @variable.parameter)
(annotation name: (identifier) @attribute)
(metadata_entry key: (identifier) @property)
(qualifier) @keyword
(parameter_qualifier) @keyword
["class" "struct" "enum" "extends" "function" "event" "operator" "implicit" "cast"
 "var" "let" "const" "default" "hint" "module" "using" "new" "as" "Cast"] @keyword
["if" "else" "switch" "case"] @keyword.conditional
["for" "while" "do" "break" "continue"] @keyword.repeat
"return" @keyword.return
[(this_expression) (super_expression)] @variable.builtin
[(string_literal) (cname_literal) (resource_literal) (tweakdbid_literal)] @string
(number_literal) @number
(boolean_literal) @boolean
(null_literal) @constant.builtin
[(line_comment) (block_comment)] @comment
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," ";" ":" "."] @punctuation.delimiter
["=" "+=" "-=" "*=" "/=" "|=" "&=" "+" "-" "*" "/" "%" "==" "!="
 "<" "<=" ">" ">=" "&&" "||" "&" "|" "^" "!" "~" "?" "->"] @operator
