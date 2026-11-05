; Standard Tree-sitter locals captures; name resolution remains the LSP's job.
[
  (source_file)
  (class_declaration)
  (struct_declaration)
  (enum_declaration)
  (function_declaration)
  (lambda_expression)
  (block)
  (if_statement)
  (while_statement)
  (for_statement)
  (switch_statement)
] @local.scope

(class_declaration name: (identifier) @local.definition)
(struct_declaration name: (identifier) @local.definition)
(enum_declaration name: (identifier) @local.definition)
(function_declaration name: (identifier) @local.definition)
(field_declaration name: (identifier) @local.definition)
(enum_variant name: (identifier) @local.definition)
(local_declaration name: (identifier) @local.definition)
(parameter name: (identifier) @local.definition)
(lambda_parameter name: (identifier) @local.definition)
(type_parameter name: (identifier) @local.definition)
(for_statement name: (identifier) @local.definition)

; These patterns match binding names, not aggregate names or as-cast types.
(pattern (identifier) @local.definition)
(field_pattern name: (identifier) @local.definition .)

(expression (identifier) @local.reference)
