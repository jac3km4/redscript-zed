(function_declaration
  body: (block) @function.inside) @function.around

(class_declaration
  body: (_) @class.inside) @class.around

(struct_declaration
  body: (_) @struct.inside) @struct.around

(if_statement
  condition: (_) @conditional.inside) @conditional.around

(while_statement
  condition: (_) @loop.inside) @loop.around

(for_statement
  (block) @loop.inside) @loop.around

(parameter
  ":" @parameter.inside) @parameter.around

(lambda_expression
  expression_body: (_) @function.inside) @function.around
