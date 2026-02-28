module vsoup

import os

// parse parses an HTML string and returns a Document.
// The caller must call Document.free() when done.
pub fn parse(html string) !Document {
	doc := C.lxb_html_document_create()
	if doc == unsafe { nil } {
		return error('failed to create HTML document')
	}
	h_data, h_len := v_to_c_string(html)
	status := C.lxb_html_document_parse(doc, h_data, h_len)
	if status != 0 {
		C.lxb_html_document_destroy(doc)
		return error('failed to parse HTML (status: ${status})')
	}
	root_node := unsafe { &C.lxb_dom_node_t(doc) }
	cache := new_selector_cache()
	return Document{
		lxb_doc: doc
		sel_cache: cache
		root: Element{
			node: root_node
			lxb_doc: doc
			sel_cache: voidptr(cache)
		}
	}
}

// parse_file reads a file and parses its contents as HTML.
pub fn parse_file(path string) !Document {
	content := os.read_file(path) or { return error('failed to read file: ${path}') }
	return parse(content)
}

// connect creates a new HTTP Connection with the given URL.
pub fn connect(url string) Connection {
	return new_connection(url)
}
