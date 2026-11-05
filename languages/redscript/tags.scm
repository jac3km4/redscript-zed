(class_declaration name: (identifier) @name) @definition.class
(struct_declaration name: (identifier) @name) @definition.struct
(enum_declaration name: (identifier) @name) @definition.enum

; Aggregate members are methods; standalone declarations are functions.
(source_file
  (declaration
    (function_declaration name: [(identifier) (operator_name)] @name) @definition.function))
(declaration_body
  (declaration
    (function_declaration name: [(identifier) (operator_name)] @name) @definition.method))

(field_declaration name: (identifier) @name) @definition.field
(enum_variant name: (identifier) @name) @definition.enum
(parameter name: (identifier) @name) @definition.parameter
(lambda_parameter name: (identifier) @name) @definition.parameter
(local_declaration name: (identifier) @name) @definition.variable
(for_statement name: (identifier) @name) @definition.variable
(module_declaration (path) @name) @definition.namespace

(call_expression function: (expression (identifier) @name)) @reference.call
(call_expression
  function: (expression (member_expression member: (identifier) @name))) @reference.call
(named_type name: (identifier) @name) @reference.type
