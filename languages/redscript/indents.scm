; Capture containers rather than declarations to avoid double-indenting bodies.
[
  (declaration_body)
  (block)
  (enum_declaration)
  (switch_statement)
  (array_literal)
  (array_type)
  (array_pattern)
  (aggregate_pattern)
  (parameters)
  (lambda_parameters)
  (arguments)
  (value_arguments)
  (type_parameters)
  (type_arguments)
  (call_type_arguments)
  (function_type)
  (parenthesized_expression)
  (interpolation)
] @indent

["}" "]" ")"] @outdent
(type_parameters ">" @outdent)
(type_arguments ">" @outdent)
(call_type_arguments ">" @outdent)

; Labels stay at switch-body indentation; statements gain one more level.
(switch_section ":" @start) @indent
