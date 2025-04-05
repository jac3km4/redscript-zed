[
  (class_declaration)
  (struct_declaration)
  (enum_declaration)
  (function_declaration)
  (block)
  (switch_statement)
  (if_statement)
  (while_statement)
  (for_statement)
  (array_literal)
] @indent.begin

[
  "}"
  "]"
  ")"
] @indent.end

(case_clause) @indent.branch
(if_statement
  alternative: (_)) @indent.branch

[
  (line_comment)
  (block_comment)
  (doc_comment)
] @indent.ignore
