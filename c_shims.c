// Shims for inline-only functions not exported in lexbor v2.6.0.
// Later lexbor versions provide _noi wrappers; this file bridges the gap.

#include "lexbor/dom/interfaces/node.h"

lxb_dom_node_type_t
lxb_dom_node_type_noi(lxb_dom_node_t *node)
{
    return node->type;
}
