// Shims for inline-only functions not exported in lexbor v2.6.0.
#ifndef vsoup_C_SHIMS_H
#define vsoup_C_SHIMS_H

#include "lexbor/dom/interfaces/node.h"

LXB_API lxb_dom_node_type_t
lxb_dom_node_type_noi(lxb_dom_node_t *node);

#endif
