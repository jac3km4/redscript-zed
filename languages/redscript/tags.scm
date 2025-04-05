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
