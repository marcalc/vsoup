module vsoup

// Document represents a parsed HTML document. It owns the underlying
// Lexbor document and must be freed with free() when no longer needed.
pub struct Document {
	lxb_doc   &C.lxb_html_document_t
	sel_cache &SelectorCache = unsafe { nil }
pub:
	root Element
}

// head returns the <head> element, or none if missing.
pub fn (d Document) head() ?Element {
	h := C.lxb_html_document_head_element_noi(d.lxb_doc)
	if h == unsafe { nil } {
		return none
	}
	return Element{
		node: unsafe { &C.lxb_dom_node_t(h) }
		lxb_doc: d.lxb_doc
		sel_cache: voidptr(d.sel_cache)
	}
}

// body returns the <body> element, or none if missing.
pub fn (d Document) body() ?Element {
	b := C.lxb_html_document_body_element_noi(d.lxb_doc)
	if b == unsafe { nil } {
		return none
	}
	return Element{
		node: unsafe { &C.lxb_dom_node_t(b) }
		lxb_doc: d.lxb_doc
		sel_cache: voidptr(d.sel_cache)
	}
}

// title returns the document's <title> text, or empty string.
pub fn (d Document) title() string {
	len := usize(0)
	data := C.lxb_html_document_title(d.lxb_doc, &len)
	return c_to_v_string(data, len)
}

// html returns the full serialized HTML of the document.
pub fn (d Document) html() string {
	return serialize_node_outer(d.root.node)
}

// pretty_html returns the full serialized HTML with indentation.
pub fn (d Document) pretty_html() string {
	return serialize_node_pretty(d.root.node)
}

// select performs a CSS selector query on the entire document.
pub fn (d Document) @select(css string) Elements {
	return d.root.@select(css)
}

// select_first returns the first element matching the CSS selector.
pub fn (d Document) select_first(css string) ?Element {
	return d.root.select_first(css)
}

// free destroys the underlying C document and cleans up all associated resources.
pub fn (d &Document) free() {
	destroy_selector_cache(d.sel_cache)
	C.lxb_html_document_destroy(d.lxb_doc)
}
