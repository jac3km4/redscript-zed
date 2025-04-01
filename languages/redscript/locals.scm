(function_declaration
  name: (identifier) @definition.function) @scope

(class_declaration
  name: (identifier) @definition.class) @scope

(struct_declaration
  name: (identifier) @definition.struct) @scope

(enum_declaration
  name: (identifier) @definition.enum) @scope

(let_statement
  name: (identifier) @definition.var) @scope

(parameter
  name: (identifier) @definition.parameter)

[
  (block)
  (if_statement)
  (while_statement)
  (for_statement)
  (switch_statement)
] @scope

(import_declaration
  (module_path) @definition.import)

(lambda_parameter
  name: (identifier) @definition.parameter)

(lambda_expression) @scope
