; Zed supports function, class, and comment text objects.
; Capture body children so inside selections exclude braces.
(function_declaration
  body: (block "{" (_)* @function.inside "}")) @function.around
(function_declaration
  body: (expression) @function.inside) @function.around
; Also allow navigating declaration-only functions.
(function_declaration !body) @function.around

(class_declaration
  (declaration_body "{" (_)* @class.inside "}")) @class.around
(struct_declaration
  (declaration_body "{" (_)* @class.inside "}")) @class.around
(enum_declaration
  "{" (enum_variant)* @class.inside "}") @class.around

; Lambdas deliberately do not become method-navigation stops.
(line_comment)+ @comment.around
(block_comment) @comment.around
