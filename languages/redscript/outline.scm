(class_declaration
  "class" @context
  name: (identifier) @name) @item

(struct_declaration
  "struct" @context
  name: (identifier) @name) @item

(enum_declaration
  "enum" @context
  name: (identifier) @name) @item

(function_declaration
  "func" @context
  name: [(identifier) (operator_name)] @name) @item

(field_declaration
  "let" @context
  name: (identifier) @name) @item

(enum_variant name: (identifier) @name) @item

(module_declaration
  "module" @context
  (path) @name) @item
