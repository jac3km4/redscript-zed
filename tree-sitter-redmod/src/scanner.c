#include "tree_sitter/parser.h"

#include <stddef.h>
#include <stdint.h>
#include <wctype.h>

enum TokenType { BLOCK_COMMENT };

void *tree_sitter_redmod_external_scanner_create(void) { return NULL; }
void tree_sitter_redmod_external_scanner_destroy(void *payload) { (void)payload; }
unsigned tree_sitter_redmod_external_scanner_serialize(void *payload, char *buffer) {
  (void)payload;
  (void)buffer;
  return 0;
}
void tree_sitter_redmod_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
  (void)payload;
  (void)buffer;
  (void)length;
}

bool tree_sitter_redmod_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
  (void)payload;
  if (!valid_symbols[BLOCK_COMMENT]) return false;
  while (iswspace(lexer->lookahead)) lexer->advance(lexer, true);
  if (lexer->lookahead != '/') return false;
  lexer->advance(lexer, false);
  if (lexer->lookahead != '*') return false;
  lexer->advance(lexer, false);

  uint32_t depth = 1;
  while (!lexer->eof(lexer)) {
    int32_t current = lexer->lookahead;
    lexer->advance(lexer, false);
    if (current == '/' && lexer->lookahead == '*') {
      lexer->advance(lexer, false);
      ++depth;
    } else if (current == '*' && lexer->lookahead == '/') {
      lexer->advance(lexer, false);
      if (--depth == 0) {
        lexer->mark_end(lexer);
        lexer->result_symbol = BLOCK_COMMENT;
        return true;
      }
    }
  }
  // Keep unfinished comments highlighted while editing, without swallowing code
  // beyond EOF. The compiler remains responsible for the diagnostic.
  lexer->mark_end(lexer);
  lexer->result_symbol = BLOCK_COMMENT;
  return true;
}
