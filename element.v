module vsoup

// Element is a non-owning view into a DOM element node.
// It wraps a Lexbor DOM node pointer and the owning document pointer.
// Elements are lightweight and can be freely copied.
pub struct Element {
	node      &C.lxb_dom_node_t
	lxb_doc   &C.lxb_html_document_t
	sel_cache voidptr
}

// tag_name returns the uppercase tag name (e.g. "DIV", "P").
pub fn (e Element) tag_name() string {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	len := usize(0)
	data := C.lxb_dom_element_tag_name(elem, &len)
	return c_to_v_string(data, len)
}

// local_name returns the lowercase local name (e.g. "div", "p").
pub fn (e Element) local_name() string {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	len := usize(0)
	data := C.lxb_dom_element_local_name(elem, &len)
	return c_to_v_string(data, len)
}

// id returns the element's id attribute value, or empty string if none.
pub fn (e Element) id() string {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	len := usize(0)
	data := C.lxb_dom_element_id_noi(elem, &len)
	return c_to_v_string(data, len)
}

// class_name returns the full class attribute value, or empty string if none.
pub fn (e Element) class_name() string {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	len := usize(0)
	data := C.lxb_dom_element_class_noi(elem, &len)
	return c_to_v_string(data, len)
}

// class_names returns the class attribute split into individual class names.
pub fn (e Element) class_names() []string {
	cls := e.class_name()
	if cls == '' {
		return []
	}
	return cls.split(' ').filter(it != '')
}

// has_class returns true if the element has the given class name.
pub fn (e Element) has_class(name string) bool {
	for cn in e.class_names() {
		if cn == name {
			return true
		}
	}
	return false
}

// attr returns the value of the given attribute, or empty string if not present.
pub fn (e Element) attr(key string) string {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	k_data, k_len := v_to_c_string(key)
	val_len := usize(0)
	data := C.lxb_dom_element_get_attribute(elem, k_data, k_len, &val_len)
	return c_to_v_string(data, val_len)
}

// has_attr returns true if the element has the given attribute.
pub fn (e Element) has_attr(key string) bool {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	k_data, k_len := v_to_c_string(key)
	return C.lxb_dom_element_has_attribute(elem, k_data, k_len)
}

// attributes returns a map of all attributes (name -> value).
pub fn (e Element) attributes() map[string]string {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	mut attrs := map[string]string{}
	mut attr := C.lxb_dom_element_first_attribute_noi(elem)
	for attr != unsafe { nil } {
		name_len := usize(0)
		name_data := C.lxb_dom_attr_local_name_noi(attr, &name_len)
		val_len := usize(0)
		val_data := C.lxb_dom_attr_value_noi(attr, &val_len)
		name := c_to_v_string(name_data, name_len)
		value := c_to_v_string(val_data, val_len)
		attrs[name] = value
		attr = C.lxb_dom_element_next_attribute_noi(attr)
	}
	return attrs
}

// text returns the text content of this element and all descendants.
pub fn (e Element) text() string {
	len := usize(0)
	data := C.lxb_dom_node_text_content(e.node, &len)
	return c_to_v_string(data, len)
}

// html returns the inner HTML (children serialized).
pub fn (e Element) html() string {
	return serialize_node_inner(e.node)
}

// outer_html returns this element's serialized HTML including itself.
pub fn (e Element) outer_html() string {
	return serialize_node_outer(e.node)
}

// node_type returns the DOM node type.
pub fn (e Element) node_type() NodeType {
	t := C.lxb_dom_node_type_noi(e.node)
	return unsafe { NodeType(t) }
}

// parent returns the parent element, or none if this is the root.
pub fn (e Element) parent() ?Element {
	p := C.lxb_dom_node_parent_noi(e.node)
	if p == unsafe { nil } {
		return none
	}
	return Element{
		node: p
		lxb_doc: e.lxb_doc
		sel_cache: e.sel_cache
	}
}

// children returns all direct child elements (skipping text/comment nodes).
pub fn (e Element) children() []Element {
	mut result := []Element{}
	mut child := C.lxb_dom_node_first_child_noi(e.node)
	for child != unsafe { nil } {
		if C.lxb_dom_node_type_noi(child) == u32(NodeType.element) {
			result << Element{
				node: child
				lxb_doc: e.lxb_doc
				sel_cache: e.sel_cache
			}
		}
		child = C.lxb_dom_node_next_noi(child)
	}
	return result
}

// child_nodes returns all direct child nodes including text and comment nodes.
pub fn (e Element) child_nodes() []Element {
	mut result := []Element{}
	mut child := C.lxb_dom_node_first_child_noi(e.node)
	for child != unsafe { nil } {
		result << Element{
			node: child
			lxb_doc: e.lxb_doc
			sel_cache: e.sel_cache
		}
		child = C.lxb_dom_node_next_noi(child)
	}
	return result
}

// first_child returns the first child element, or none if empty.
pub fn (e Element) first_child() ?Element {
	mut child := C.lxb_dom_node_first_child_noi(e.node)
	for child != unsafe { nil } {
		if C.lxb_dom_node_type_noi(child) == u32(NodeType.element) {
			return Element{
				node: child
				lxb_doc: e.lxb_doc
				sel_cache: e.sel_cache
			}
		}
		child = C.lxb_dom_node_next_noi(child)
	}
	return none
}

// last_child returns the last child element, or none if empty.
pub fn (e Element) last_child() ?Element {
	mut child := C.lxb_dom_node_last_child_noi(e.node)
	for child != unsafe { nil } {
		if C.lxb_dom_node_type_noi(child) == u32(NodeType.element) {
			return Element{
				node: child
				lxb_doc: e.lxb_doc
				sel_cache: e.sel_cache
			}
		}
		child = C.lxb_dom_node_prev_noi(child)
	}
	return none
}

// next_sibling returns the next sibling element, or none.
pub fn (e Element) next_sibling() ?Element {
	mut sib := C.lxb_dom_node_next_noi(e.node)
	for sib != unsafe { nil } {
		if C.lxb_dom_node_type_noi(sib) == u32(NodeType.element) {
			return Element{
				node: sib
				lxb_doc: e.lxb_doc
				sel_cache: e.sel_cache
			}
		}
		sib = C.lxb_dom_node_next_noi(sib)
	}
	return none
}

// prev_sibling returns the previous sibling element, or none.
pub fn (e Element) prev_sibling() ?Element {
	mut sib := C.lxb_dom_node_prev_noi(e.node)
	for sib != unsafe { nil } {
		if C.lxb_dom_node_type_noi(sib) == u32(NodeType.element) {
			return Element{
				node: sib
				lxb_doc: e.lxb_doc
				sel_cache: e.sel_cache
			}
		}
		sib = C.lxb_dom_node_prev_noi(sib)
	}
	return none
}

// --- CSS Selector methods ---

// select returns all descendant elements matching the CSS selector.
pub fn (e Element) @select(css string) Elements {
	mut ptrs := []voidptr{}
	if e.sel_cache != unsafe { nil } {
		ptrs = selector_find_cached(unsafe { &SelectorCache(e.sel_cache) }, e.node, css,
			false) or { return Elements{} }
	} else {
		ptrs = selector_find(e.lxb_doc, e.node, css, false) or { return Elements{} }
	}
	mut items := []Element{cap: ptrs.len}
	for p in ptrs {
		items << Element{
			node: unsafe { &C.lxb_dom_node_t(p) }
			lxb_doc: e.lxb_doc
			sel_cache: e.sel_cache
		}
	}
	return Elements{
		items: items
	}
}

// select_first returns the first descendant element matching the CSS selector.
pub fn (e Element) select_first(css string) ?Element {
	mut ptrs := []voidptr{}
	if e.sel_cache != unsafe { nil } {
		ptrs = selector_find_cached(unsafe { &SelectorCache(e.sel_cache) }, e.node, css,
			true) or { return none }
	} else {
		ptrs = selector_find(e.lxb_doc, e.node, css, true) or { return none }
	}
	if ptrs.len == 0 {
		return none
	}
	return Element{
		node: unsafe { &C.lxb_dom_node_t(ptrs[0]) }
		lxb_doc: e.lxb_doc
		sel_cache: e.sel_cache
	}
}

// get_element_by_id finds a descendant element with the given id.
pub fn (e Element) get_element_by_id(id string) ?Element {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	id_data, id_len := v_to_c_string(id)
	found := C.lxb_dom_element_by_id(elem, id_data, id_len)
	if found == unsafe { nil } {
		return none
	}
	return Element{
		node: unsafe { &C.lxb_dom_node_t(found) }
		lxb_doc: e.lxb_doc
		sel_cache: e.sel_cache
	}
}

// get_elements_by_tag returns all descendant elements with the given tag name.
pub fn (e Element) get_elements_by_tag(tag string) Elements {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	dom_doc := unsafe { &C.lxb_dom_document_t(e.lxb_doc) }
	col := C.lxb_dom_collection_make_noi(dom_doc, 16)
	if col == unsafe { nil } {
		return Elements{}
	}
	tag_data, tag_len := v_to_c_string(tag)
	C.lxb_dom_elements_by_tag_name(elem, col, tag_data, tag_len)
	result := collection_to_elements(col, e.lxb_doc, e.sel_cache)
	C.lxb_dom_collection_destroy(col, true)
	return result
}

// get_elements_by_class returns all descendant elements with the given class name.
pub fn (e Element) get_elements_by_class(name string) Elements {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	dom_doc := unsafe { &C.lxb_dom_document_t(e.lxb_doc) }
	col := C.lxb_dom_collection_make_noi(dom_doc, 16)
	if col == unsafe { nil } {
		return Elements{}
	}
	name_data, name_len := v_to_c_string(name)
	C.lxb_dom_elements_by_class_name(elem, col, name_data, name_len)
	result := collection_to_elements(col, e.lxb_doc, e.sel_cache)
	C.lxb_dom_collection_destroy(col, true)
	return result
}

// --- DOM Manipulation methods ---

// set_attr sets the value of an attribute.
pub fn (e Element) set_attr(key string, val string) {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	k_data, k_len := v_to_c_string(key)
	v_data, v_len := v_to_c_string(val)
	C.lxb_dom_element_set_attribute(elem, k_data, k_len, v_data, v_len)
}

// remove_attr removes an attribute from the element.
pub fn (e Element) remove_attr(key string) {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	k_data, k_len := v_to_c_string(key)
	C.lxb_dom_element_remove_attribute(elem, k_data, k_len)
}

// add_class adds a class name to the element's class attribute.
pub fn (e Element) add_class(name string) {
	current := e.class_name()
	if current == '' {
		e.set_attr('class', name)
		return
	}
	for cn in current.split(' ') {
		if cn == name {
			return
		}
	}
	e.set_attr('class', current + ' ' + name)
}

// remove_class removes a class name from the element's class attribute.
pub fn (e Element) remove_class(name string) {
	current := e.class_name()
	if current == '' {
		return
	}
	classes := current.split(' ').filter(it != name && it != '')
	if classes.len == 0 {
		e.remove_attr('class')
	} else {
		e.set_attr('class', classes.join(' '))
	}
}

// append parses the HTML fragment and appends the resulting nodes as children.
pub fn (e Element) append(html_str string) {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	h_data, h_len := v_to_c_string(html_str)
	fragment := C.lxb_html_document_parse_fragment(e.lxb_doc, elem, h_data, h_len)
	if fragment == unsafe { nil } {
		return
	}
	mut child := C.lxb_dom_node_first_child_noi(fragment)
	for child != unsafe { nil } {
		next := C.lxb_dom_node_next_noi(child)
		C.lxb_dom_node_remove(child)
		C.lxb_dom_node_insert_child(e.node, child)
		child = unsafe { next }
	}
	C.lxb_dom_node_destroy(fragment)
}

// prepend parses the HTML fragment and inserts the resulting nodes before existing children.
pub fn (e Element) prepend(html_str string) {
	elem := unsafe { &C.lxb_dom_element_t(e.node) }
	h_data, h_len := v_to_c_string(html_str)
	fragment := C.lxb_html_document_parse_fragment(e.lxb_doc, elem, h_data, h_len)
	if fragment == unsafe { nil } {
		return
	}
	first := C.lxb_dom_node_first_child_noi(e.node)
	mut child := C.lxb_dom_node_first_child_noi(fragment)
	for child != unsafe { nil } {
		next := C.lxb_dom_node_next_noi(child)
		C.lxb_dom_node_remove(child)
		if first != unsafe { nil } {
			C.lxb_dom_node_insert_before(first, child)
		} else {
			C.lxb_dom_node_insert_child(e.node, child)
		}
		child = unsafe { next }
	}
	C.lxb_dom_node_destroy(fragment)
}

// remove removes this element from its parent.
pub fn (e Element) remove() {
	C.lxb_dom_node_remove(e.node)
}

// empty removes all children of this element.
pub fn (e Element) empty() {
	mut child := C.lxb_dom_node_first_child_noi(e.node)
	for child != unsafe { nil } {
		next := C.lxb_dom_node_next_noi(child)
		C.lxb_dom_node_remove(child)
		child = unsafe { next }
	}
}

// set_text sets the text content of this element, replacing all children.
pub fn (e Element) set_text(text string) {
	t_data, t_len := v_to_c_string(text)
	C.lxb_dom_node_text_content_set(e.node, t_data, t_len)
}

// --- Helpers ---

fn collection_to_elements(col &C.lxb_dom_collection_t, doc &C.lxb_html_document_t, cache voidptr) Elements {
	length := C.lxb_dom_collection_length_noi(col)
	mut items := []Element{cap: int(length)}
	for i := usize(0); i < length; i++ {
		node := C.lxb_dom_collection_node_noi(col, i)
		if node != unsafe { nil } {
			items << unsafe {
				Element{
					node: node
					lxb_doc: doc
					sel_cache: cache
				}
			}
		}
	}
	return Elements{
		items: items
	}
}
