module vsoup

// C↔V string conversion and serialization callbacks

// Convert C string (pointer + length) to V string by copying the data.
fn c_to_v_string(data &u8, len usize) string {
	if data == unsafe { nil } || len == 0 {
		return ''
	}
	return unsafe { tos(data, int(len)) }.clone()
}

// Convert V string to C pointer + length for passing to Lexbor functions.
fn v_to_c_string(s string) (&u8, usize) {
	return s.str, usize(s.len)
}

// Serialization callback that appends data to a []u8 buffer.
fn serialize_callback(data &u8, len usize, ctx voidptr) u32 {
	if data == unsafe { nil } || len == 0 {
		return 0
	}
	mut buf := unsafe { &[]u8(ctx) }
	unsafe {
		for i := usize(0); i < len; i++ {
			buf << data[i]
		}
	}
	return 0
}

fn get_serialize_cb() voidptr {
	return voidptr(serialize_callback)
}

// Serialize a node's inner HTML (children only, not the node itself).
fn serialize_node_inner(node &C.lxb_dom_node_t) string {
	mut buf := []u8{}
	mut child := C.lxb_dom_node_first_child_noi(node)
	for child != unsafe { nil } {
		C.lxb_html_serialize_tree_cb(child, get_serialize_cb(), voidptr(&buf))
		child = unsafe { C.lxb_dom_node_next_noi(child) }
	}
	return buf.bytestr()
}

// Serialize a node's outer HTML (the node itself + all children).
fn serialize_node_outer(node &C.lxb_dom_node_t) string {
	mut buf := []u8{}
	C.lxb_html_serialize_tree_cb(node, get_serialize_cb(), voidptr(&buf))
	return buf.bytestr()
}

// Serialize a node tree with pretty printing.
fn serialize_node_pretty(node &C.lxb_dom_node_t) string {
	mut buf := []u8{}
	C.lxb_html_serialize_pretty_deep_cb(node, 0, 0, get_serialize_cb(), voidptr(&buf))
	return buf.bytestr()
}

// --- CSS Selector support ---

// SelectorCache caches compiled CSS selectors for reuse across queries.
// Design: each unique CSS selector string gets its own dedicated `lxb_css_parser_t`,
// which owns its memory pool and the compiled `lxb_css_selector_list_t`. A single
// shared `lxb_selectors_t` engine is used for all find operations. This avoids
// re-parsing selectors on every query while keeping each parser's memory independent
// (calling `lxb_css_parser_clean()` would invalidate cached lists, so we don't share parsers).
// Cleanup: `lxb_css_parser_destroy(p, true)` frees the parser, its memory pool, and all
// selector lists allocated through it.
struct SelectorCache {
mut:
	sel_engine &C.lxb_selectors_t = unsafe { nil }
	parsers    map[string]voidptr // CSS string -> &C.lxb_css_parser_t
	lists      map[string]voidptr // CSS string -> &C.lxb_css_selector_list_t
}

fn new_selector_cache() &SelectorCache {
	return &SelectorCache{}
}

fn destroy_selector_cache(cache &SelectorCache) {
	if cache == unsafe { nil } {
		return
	}
	mut c := unsafe { cache }
	if c.sel_engine != unsafe { nil } {
		C.lxb_selectors_destroy(c.sel_engine, true)
	}
	// Destroying each parser also frees its memory pool and all allocated selector lists
	for _, p in c.parsers {
		if p != unsafe { nil } {
			C.lxb_css_parser_destroy(unsafe { &C.lxb_css_parser_t(p) }, true)
		}
	}
}

// Callback for lxb_selectors_find that accumulates matched nodes.
fn selector_find_callback(node &C.lxb_dom_node_t, spec u32, ctx voidptr) u32 {
	mut results := unsafe { &[]voidptr(ctx) }
	unsafe {
		results << voidptr(node)
	}
	return 0
}

fn get_selector_find_cb() voidptr {
	return voidptr(selector_find_callback)
}

// Perform a CSS selector query. Creates fresh parser/selectors per call (matches Lexbor example pattern).
fn selector_find(doc &C.lxb_html_document_t, root &C.lxb_dom_node_t, css string, match_first bool) ![]voidptr {
	// Create CSS parser
	css_parser := C.lxb_css_parser_create()
	if css_parser == unsafe { nil } {
		return error('failed to create CSS parser')
	}
	status := C.lxb_css_parser_init(css_parser, unsafe { nil })
	if status != 0 {
		C.lxb_css_parser_destroy(css_parser, true)
		return error('failed to init CSS parser')
	}

	// Create selectors engine
	selectors := C.lxb_selectors_create()
	if selectors == unsafe { nil } {
		C.lxb_css_parser_destroy(css_parser, true)
		return error('failed to create selectors engine')
	}
	sel_status := C.lxb_selectors_init(selectors)
	if sel_status != 0 {
		C.lxb_selectors_destroy(selectors, true)
		C.lxb_css_parser_destroy(css_parser, true)
		return error('failed to init selectors engine')
	}

	// Parse selector
	data, length := v_to_c_string(css)
	list := C.lxb_css_selectors_parse(css_parser, data, length)
	if list == unsafe { nil } {
		C.lxb_selectors_destroy(selectors, true)
		C.lxb_css_parser_destroy(css_parser, true)
		return error('failed to parse CSS selector: ${css}')
	}

	// Set options
	if match_first {
		C.lxb_selectors_opt_set_noi(selectors, 1 << 2) // LXB_SELECTORS_OPT_MATCH_FIRST
	}

	// Find matches
	mut results := []voidptr{}
	find_status := C.lxb_selectors_find(selectors, root, list, get_selector_find_cb(),
		voidptr(&results))

	// Cleanup (order matters: selectors, then parser, then list memory)
	C.lxb_selectors_destroy(selectors, true)
	C.lxb_css_parser_destroy(css_parser, true)
	C.lxb_css_selector_list_destroy_memory(list)

	if find_status != 0 {
		return error('CSS selector find failed')
	}

	return results
}

// Cached CSS selector query. Compiles each unique selector once and caches it.
// Each selector gets its own CSS parser (owns its memory pool independently).
// The selectors engine is shared across all queries.
fn selector_find_cached(cache &SelectorCache, root &C.lxb_dom_node_t, css string, match_first bool) ![]voidptr {
	mut c := unsafe { cache }

	// Lazy-init selectors engine (one-time)
	if c.sel_engine == unsafe { nil } {
		c.sel_engine = C.lxb_selectors_create()
		if c.sel_engine == unsafe { nil } {
			return error('failed to create selectors engine')
		}
		sel_status := C.lxb_selectors_init(c.sel_engine)
		if sel_status != 0 {
			C.lxb_selectors_destroy(c.sel_engine, true)
			c.sel_engine = unsafe { nil }
			return error('failed to init selectors engine')
		}
	}

	// Look up cached selector list, or compile and cache it
	mut list := &C.lxb_css_selector_list_t(unsafe { nil })
	if css in c.lists {
		list = unsafe { &C.lxb_css_selector_list_t(c.lists[css]) }
	} else {
		// Create a dedicated parser for this selector (owns its own memory)
		parser := C.lxb_css_parser_create()
		if parser == unsafe { nil } {
			return error('failed to create CSS parser')
		}
		status := C.lxb_css_parser_init(parser, unsafe { nil })
		if status != 0 {
			C.lxb_css_parser_destroy(parser, true)
			return error('failed to init CSS parser')
		}
		data, length := v_to_c_string(css)
		list = C.lxb_css_selectors_parse(parser, data, length)
		if list == unsafe { nil } {
			C.lxb_css_parser_destroy(parser, true)
			return error('failed to parse CSS selector: ${css}')
		}
		c.parsers[css] = voidptr(parser)
		c.lists[css] = voidptr(list)
	}

	// Set match option (reset each call since engine is shared)
	if match_first {
		C.lxb_selectors_opt_set_noi(c.sel_engine, 1 << 2)
	} else {
		C.lxb_selectors_opt_set_noi(c.sel_engine, 0)
	}

	// Find matches
	mut results := []voidptr{}
	find_status := C.lxb_selectors_find(c.sel_engine, root, list, get_selector_find_cb(),
		voidptr(&results))

	if find_status != 0 {
		return error('CSS selector find failed')
	}

	return results
}
