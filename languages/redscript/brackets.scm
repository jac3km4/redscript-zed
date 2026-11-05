("(" @open ")" @close)
("[" @open "]" @close)
("{" @open "}" @close)

; Only type lists use angle brackets as delimiters, not comparisons.
(type_parameters "<" @open ">" @close)
(type_arguments "<" @open ">" @close)
(call_type_arguments "<" @open ">" @close)

(string_literal "\"" @open "\"" @close)
(cname_literal "n\"" @open "\"" @close)
(resource_literal "r\"" @open "\"" @close)
(tweakdbid_literal "t\"" @open "\"" @close)
(interpolated_string "s\"" @open "\"" @close)
(interpolation "\\(" @open ")" @close)
