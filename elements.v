module vsoup

// Elements is an ordered collection of Element values, similar to JSoup's Elements.
pub struct Elements {
pub:
	items []Element
}

// len returns the number of elements in the collection.
pub fn (es Elements) len() int {
	return es.items.len
}

// is_empty returns true if the collection has no elements.
pub fn (es Elements) is_empty() bool {
	return es.items.len == 0
}

// first returns the first element, or none if empty.
pub fn (es Elements) first() ?Element {
	if es.items.len == 0 {
		return none
	}
	return es.items[0]
}

// last returns the last element, or none if empty.
pub fn (es Elements) last() ?Element {
	if es.items.len == 0 {
		return none
	}
	return es.items[es.items.len - 1]
}

// at returns the element at index i, or none if out of bounds.
pub fn (es Elements) at(i int) ?Element {
	if i < 0 || i >= es.items.len {
		return none
	}
	return es.items[i]
}

// text returns the combined text content of all elements, separated by spaces.
pub fn (es Elements) text() string {
	mut parts := []string{cap: es.items.len}
	for e in es.items {
		t := e.text()
		if t != '' {
			parts << t
		}
	}
	return parts.join(' ')
}

// attr returns the attribute value from the first element that has it, or empty string.
pub fn (es Elements) attr(key string) string {
	for e in es.items {
		if e.has_attr(key) {
			return e.attr(key)
		}
	}
	return ''
}

// each_attr returns a list of the attribute value from each element (empty string if missing).
pub fn (es Elements) each_attr(key string) []string {
	mut result := []string{cap: es.items.len}
	for e in es.items {
		result << e.attr(key)
	}
	return result
}

// select performs a CSS selector query on each element and returns the combined results.
pub fn (es Elements) @select(css string) Elements {
	mut all := []Element{}
	for e in es.items {
		found := e.@select(css)
		all << found.items
	}
	return Elements{
		items: all
	}
}

// iter returns the underlying array for use in `for` loops.
pub fn (es Elements) iter() []Element {
	return es.items
}

// --- DOM Manipulation (Phase 3) ---

// set_attr sets an attribute on all elements in the collection.
pub fn (es Elements) set_attr(key string, val string) {
	for e in es.items {
		e.set_attr(key, val)
	}
}

// remove_attr removes an attribute from all elements in the collection.
pub fn (es Elements) remove_attr(key string) {
	for e in es.items {
		e.remove_attr(key)
	}
}

// add_class adds a class to all elements in the collection.
pub fn (es Elements) add_class(name string) {
	for e in es.items {
		e.add_class(name)
	}
}

// remove_class removes a class from all elements in the collection.
pub fn (es Elements) remove_class(name string) {
	for e in es.items {
		e.remove_class(name)
	}
}

// remove removes all elements in the collection from their parents.
pub fn (es Elements) remove() {
	for e in es.items {
		e.remove()
	}
}
