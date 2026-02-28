module vsoup

// Compile lexbor directly — no CMake required.
// Per-module unity builds (lexbor_*.c) + two files compiled separately
// to avoid static symbol conflicts across translation units.
#flag -DLEXBOR_STATIC
#flag -I @VMODROOT
#flag -I @VMODROOT/lexbor/source
#flag linux -lm
#flag @VMODROOT/lexbor/lexbor_core.c
#flag @VMODROOT/lexbor/lexbor_dom.c
#flag @VMODROOT/lexbor/lexbor_html.c
#flag @VMODROOT/lexbor/source/lexbor/html/interface.c
#flag @VMODROOT/lexbor/lexbor_css.c
#flag @VMODROOT/lexbor/source/lexbor/css/value.c
#flag @VMODROOT/lexbor/lexbor_extra.c
#flag @VMODROOT/c_shims.c

// Include the main lexbor headers
#include "lexbor/html/html.h"
#include "lexbor/dom/dom.h"
#include "lexbor/css/css.h"
#include "lexbor/selectors/selectors.h"
#include "lexbor/html/serialize.h"
#include "c_shims.h"

// --- Opaque C types (all are typedefs in Lexbor) ---

@[typedef]
struct C.lxb_html_document_t {}

@[typedef]
struct C.lxb_html_parser_t {}

@[typedef]
struct C.lxb_dom_node_t {}

@[typedef]
struct C.lxb_dom_element_t {}

@[typedef]
struct C.lxb_dom_attr_t {}

@[typedef]
struct C.lxb_dom_text_t {}

@[typedef]
struct C.lxb_dom_collection_t {}

@[typedef]
struct C.lxb_dom_document_t {}

@[typedef]
struct C.lxb_dom_document_fragment_t {}

@[typedef]
struct C.lxb_html_head_element_t {}

@[typedef]
struct C.lxb_html_body_element_t {}

@[typedef]
struct C.lxb_html_element_t {}

@[typedef]
struct C.lxb_css_parser_t {}

@[typedef]
struct C.lxb_css_selectors_t {}

@[typedef]
struct C.lxb_css_selector_list_t {}

@[typedef]
struct C.lxb_selectors_t {}

// lxb_css_selector_specificity_t is uint32_t (not a struct)

@[typedef]
struct C.lexbor_str_t {}

// --- HTML Document lifecycle ---

fn C.lxb_html_document_create() &C.lxb_html_document_t
fn C.lxb_html_document_clean(document &C.lxb_html_document_t)
fn C.lxb_html_document_destroy(document &C.lxb_html_document_t) &C.lxb_html_document_t
fn C.lxb_html_document_parse(document &C.lxb_html_document_t, html &u8, size usize) u32

// Document properties (inline -> _noi)
fn C.lxb_html_document_head_element_noi(document &C.lxb_html_document_t) &C.lxb_html_head_element_t
fn C.lxb_html_document_body_element_noi(document &C.lxb_html_document_t) &C.lxb_html_body_element_t
fn C.lxb_html_document_title(document &C.lxb_html_document_t, len &usize) &u8

// Document element creation
fn C.lxb_html_document_create_element_noi(document &C.lxb_html_document_t, local_name &u8, lname_len usize, reserved voidptr) &C.lxb_html_element_t

// Fragment parsing
fn C.lxb_html_document_parse_fragment(document &C.lxb_html_document_t, element &C.lxb_dom_element_t, html &u8, size usize) &C.lxb_dom_node_t

// --- DOM Node traversal (inline -> _noi) ---

fn C.lxb_dom_node_first_child_noi(node &C.lxb_dom_node_t) &C.lxb_dom_node_t
fn C.lxb_dom_node_last_child_noi(node &C.lxb_dom_node_t) &C.lxb_dom_node_t
fn C.lxb_dom_node_next_noi(node &C.lxb_dom_node_t) &C.lxb_dom_node_t
fn C.lxb_dom_node_prev_noi(node &C.lxb_dom_node_t) &C.lxb_dom_node_t
fn C.lxb_dom_node_parent_noi(node &C.lxb_dom_node_t) &C.lxb_dom_node_t

// Node type and tag
fn C.lxb_dom_node_type_noi(node &C.lxb_dom_node_t) u32
fn C.lxb_dom_node_tag_id_noi(node &C.lxb_dom_node_t) usize

// Node content
fn C.lxb_dom_node_text_content(node &C.lxb_dom_node_t, len &usize) &u8
fn C.lxb_dom_node_text_content_set(node &C.lxb_dom_node_t, content &u8, len usize) u32

// Node manipulation
fn C.lxb_dom_node_insert_child(to &C.lxb_dom_node_t, node &C.lxb_dom_node_t)
fn C.lxb_dom_node_insert_before(to &C.lxb_dom_node_t, node &C.lxb_dom_node_t)
fn C.lxb_dom_node_insert_after(to &C.lxb_dom_node_t, node &C.lxb_dom_node_t)
fn C.lxb_dom_node_remove(node &C.lxb_dom_node_t)
fn C.lxb_dom_node_destroy(node &C.lxb_dom_node_t) &C.lxb_dom_node_t

// --- DOM Element ---

fn C.lxb_dom_element_local_name(element &C.lxb_dom_element_t, len &usize) &u8
fn C.lxb_dom_element_tag_name(element &C.lxb_dom_element_t, len &usize) &u8
fn C.lxb_dom_element_qualified_name(element &C.lxb_dom_element_t, len &usize) &u8

// ID and class (inline -> _noi)
fn C.lxb_dom_element_id_noi(element &C.lxb_dom_element_t, len &usize) &u8
fn C.lxb_dom_element_class_noi(element &C.lxb_dom_element_t, len &usize) &u8

// Attribute operations
fn C.lxb_dom_element_get_attribute(element &C.lxb_dom_element_t, qualified_name &u8, qn_len usize, value_len &usize) &u8
fn C.lxb_dom_element_has_attribute(element &C.lxb_dom_element_t, qualified_name &u8, qn_len usize) bool
fn C.lxb_dom_element_set_attribute(element &C.lxb_dom_element_t, qualified_name &u8, qn_len usize, value &u8, value_len usize) &C.lxb_dom_attr_t
fn C.lxb_dom_element_remove_attribute(element &C.lxb_dom_element_t, qualified_name &u8, qn_len usize) u32

// Attribute iteration (inline -> _noi)
fn C.lxb_dom_element_first_attribute_noi(element &C.lxb_dom_element_t) &C.lxb_dom_attr_t
fn C.lxb_dom_element_next_attribute_noi(attr &C.lxb_dom_attr_t) &C.lxb_dom_attr_t

// Element search
fn C.lxb_dom_elements_by_tag_name(root &C.lxb_dom_element_t, collection &C.lxb_dom_collection_t, qualified_name &u8, len usize) u32
fn C.lxb_dom_elements_by_class_name(root &C.lxb_dom_element_t, collection &C.lxb_dom_collection_t, class_name &u8, len usize) u32
fn C.lxb_dom_element_by_id(root &C.lxb_dom_element_t, id &u8, len usize) &C.lxb_dom_element_t

// --- DOM Attribute ---

fn C.lxb_dom_attr_local_name_noi(attr &C.lxb_dom_attr_t, len &usize) &u8
fn C.lxb_dom_attr_value_noi(attr &C.lxb_dom_attr_t, len &usize) &u8
fn C.lxb_dom_attr_qualified_name(attr &C.lxb_dom_attr_t, len &usize) &u8

// --- DOM Document ---

fn C.lxb_dom_document_create_element(document &C.lxb_dom_document_t, local_name &u8, lname_len usize, reserved voidptr) &C.lxb_dom_element_t
fn C.lxb_dom_document_create_text_node(document &C.lxb_dom_document_t, data &u8, len usize) &C.lxb_dom_text_t

// --- DOM Collection (inline -> _noi) ---

fn C.lxb_dom_collection_make_noi(document &C.lxb_dom_document_t, start_list_size usize) &C.lxb_dom_collection_t
fn C.lxb_dom_collection_destroy(col &C.lxb_dom_collection_t, self_destroy bool) &C.lxb_dom_collection_t
fn C.lxb_dom_collection_element_noi(col &C.lxb_dom_collection_t, idx usize) &C.lxb_dom_element_t
fn C.lxb_dom_collection_node_noi(col &C.lxb_dom_collection_t, idx usize) &C.lxb_dom_node_t
fn C.lxb_dom_collection_length_noi(col &C.lxb_dom_collection_t) usize
fn C.lxb_dom_collection_clean_noi(col &C.lxb_dom_collection_t)

// --- HTML Serialization ---

fn C.lxb_html_serialize_cb(node &C.lxb_dom_node_t, cb voidptr, ctx voidptr) u32
fn C.lxb_html_serialize_tree_cb(node &C.lxb_dom_node_t, cb voidptr, ctx voidptr) u32
fn C.lxb_html_serialize_deep_cb(node &C.lxb_dom_node_t, cb voidptr, ctx voidptr) u32
fn C.lxb_html_serialize_pretty_tree_cb(node &C.lxb_dom_node_t, opt int, indent usize, cb voidptr, ctx voidptr) u32
fn C.lxb_html_serialize_pretty_deep_cb(node &C.lxb_dom_node_t, opt int, indent usize, cb voidptr, ctx voidptr) u32

// --- CSS Parser ---

fn C.lxb_css_parser_create() &C.lxb_css_parser_t
fn C.lxb_css_parser_init(parser &C.lxb_css_parser_t, tkz voidptr) u32
fn C.lxb_css_parser_selectors_init(parser &C.lxb_css_parser_t) u32
fn C.lxb_css_parser_selectors_destroy(parser &C.lxb_css_parser_t)
fn C.lxb_css_parser_clean(parser &C.lxb_css_parser_t)
fn C.lxb_css_parser_destroy(parser &C.lxb_css_parser_t, self_destroy bool) &C.lxb_css_parser_t

// CSS selector parsing
fn C.lxb_css_selectors_parse(parser &C.lxb_css_parser_t, data &u8, length usize) &C.lxb_css_selector_list_t
fn C.lxb_css_selector_list_destroy_memory(list &C.lxb_css_selector_list_t)

// --- DOM Selectors engine ---

fn C.lxb_selectors_create() &C.lxb_selectors_t
fn C.lxb_selectors_init(selectors &C.lxb_selectors_t) u32
fn C.lxb_selectors_destroy(selectors &C.lxb_selectors_t, self_destroy bool) &C.lxb_selectors_t
fn C.lxb_selectors_find(selectors &C.lxb_selectors_t, root &C.lxb_dom_node_t, list &C.lxb_css_selector_list_t, cb voidptr, ctx voidptr) u32
fn C.lxb_selectors_opt_set_noi(selectors &C.lxb_selectors_t, opt int)
