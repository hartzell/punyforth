// This is the outer text interpreter (REPL) implemented in binary forth.

.section .rodata
.align 4

outer_interpreter:
    .int xt_word                           // ( a len )
    .int xt_dup2
    .int xt_find, xt_dup, xt_branch0       // dictionary lookup returns (link | 0)
    lbl not_found_in_dictionary
    .int xt_dup, xt_link2xt                // get the xt and flags of the word
    .int xt_swap, xt_is_immediate, xt_invert
    .int xt_branch0
    lbl interpret                          // if immediate word then interpet even if we're in compilation mode
    .int xt_state, xt_fetch                // if non immediate word, interpret or compile depending on state    
    .int xt_branch0
    lbl interpret
    .int xt_nip, xt_nip                         
    .int xt_comma                          // compile the xt into the current word definition
    .int xt_branch
    lbl outer_interpreter 
interpret:
    .int xt_nip, xt_nip                          
    .int xt_execute
    .int xt_branch
    lbl outer_interpreter 
not_found_in_dictionary:                   // word was not found in the dictionary try to convert it to number
    .int xt_drop
    .int xt_dup2                           // save (len wordadr) for printing if error occurs during conversion
    .int xt_tonumber
    .int xt_branch0
    lbl invalid_number
    .int xt_nip, xt_nip                    // drop saved word 
    .int xt_state, xt_fetch, xt_branch0    // depending on state compile number literal or push number to the stack
    lbl outer_interpreter
    .int xt_literal                        // we're in compile mode, compile a literal number
    .int xt_branch
    lbl outer_interpreter 
invalid_number:
    .int xt_btick, undef_word_error, xt_type
    .int xt_typecounted
    .int xt_btick, 13, xt_emit
    .int xt_btick, 10, xt_emit
    .int xt_tib, xt_inputlen, xt_fetch, xt_plus, xt_toin, xt_store // skip rest of the inputbuffer
    .int xt_openbracket // switch back to interpret mode
    .int xt_branch
    lbl outer_interpreter
