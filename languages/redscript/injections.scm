; The community grammar represents doc comments as line comments.
((line_comment) @injection.content
  (#match? @injection.content "^///([^/]|$)")
  (#set! injection.language "markdown-inline"))
