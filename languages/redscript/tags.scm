; Class-like definitions
(class_declaration
  name: (identifier) @name) @definition.class

(struct_declaration
  name: (identifier) @name) @definition.struct

(enum_declaration
  name: (identifier) @name) @definition.enum

; Function definitions
(function_declaration
  name: (identifier) @name) @definition.method

; Field/Property definitions
(field_declaration
  name: (identifier) @name) @definition.field

; Enum entries
(enum_entry
  name: (identifier) @name) @definition.enum

; Parameters in functions
(parameter
  name: (identifier) @name) @definition.parameter

; Let declarations
(let_statement
  name: (identifier) @name) @definition.variable

; Module definitions
(module_path
  (identifier) @name) @definition.namespace

; References
(call_expression
  function: (identifier) @name) @reference.call

(member_expression
  member: (identifier) @name) @reference.property

(named_type
  name: (identifier) @name) @reference.type

; Import references
(import_declaration
  (module_path) @name) @reference.import

; Lambda functions
(lambda_expression
  (lambda_parameter
    name: (identifier) @name)) @definition.function

; Type references
(cast_expression
  type: (type)) @reference.type

(type_arguments
  (type)) @reference.type

; Method calls
(call_expression
  function: (member_expression
    member: (identifier) @name)) @reference.method
