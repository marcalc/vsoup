module vsoup

fn test_element_tag_name() {
	doc := parse('<div>test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	assert div.tag_name() == 'DIV'
	assert div.local_name() == 'div'
}

fn test_element_id() {
	doc := parse('<div id="main">test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	assert div.id() == 'main'
}

fn test_element_class_name() {
	doc := parse('<div class="foo bar">test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	assert div.class_name() == 'foo bar'
}

fn test_element_class_names() {
	doc := parse('<div class="foo bar baz">test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	names := div.class_names()
	assert names.len == 3
	assert 'foo' in names
	assert 'bar' in names
	assert 'baz' in names
}

fn test_element_has_class() {
	doc := parse('<div class="foo bar">test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	assert div.has_class('foo')
	assert div.has_class('bar')
	assert !div.has_class('baz')
}

fn test_element_attr() {
	doc := parse('<a href="/test" target="_blank">link</a>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	a := body.children()[0]
	assert a.attr('href') == '/test'
	assert a.attr('target') == '_blank'
}

fn test_element_has_attr() {
	doc := parse('<div data-x="1">test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	assert div.has_attr('data-x')
	assert !div.has_attr('data-y')
}

fn test_element_attributes_map() {
	doc := parse('<div id="main" class="c" data-x="1">test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	attrs := div.attributes()
	assert attrs['id'] == 'main'
	assert attrs['class'] == 'c'
	assert attrs['data-x'] == '1'
}

fn test_element_text() {
	doc := parse('<div><p>Hello</p> <p>World</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	text := div.text()
	assert text.contains('Hello')
	assert text.contains('World')
}

fn test_element_inner_html() {
	doc := parse('<div><p>Hello</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	assert div.html() == '<p>Hello</p>'
}

fn test_element_outer_html() {
	doc := parse('<div><p>Hello</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	outer := div.outer_html()
	assert outer.contains('<div>')
	assert outer.contains('<p>Hello</p>')
	assert outer.contains('</div>')
}

fn test_element_node_type() {
	doc := parse('<div>test</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	assert div.node_type() == .element
}

fn test_element_parent() {
	doc := parse('<div><p>test</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	p := div.children()[0]
	parent := p.parent() or { panic('no parent') }
	assert parent.local_name() == 'div'
}

fn test_element_children() {
	doc := parse('<ul><li>A</li><li>B</li><li>C</li></ul>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	ul := body.children()[0]
	children := ul.children()
	assert children.len == 3
	assert children[0].text() == 'A'
	assert children[1].text() == 'B'
	assert children[2].text() == 'C'
}

fn test_element_first_last_child() {
	doc := parse('<ul><li>A</li><li>B</li><li>C</li></ul>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	ul := body.children()[0]
	first := ul.first_child() or { panic('no first child') }
	assert first.text() == 'A'
	last := ul.last_child() or { panic('no last child') }
	assert last.text() == 'C'
}

fn test_element_siblings() {
	doc := parse('<div><p>A</p><p>B</p><p>C</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	children := div.children()
	b := children[1]
	prev := b.prev_sibling() or { panic('no prev') }
	assert prev.text() == 'A'
	next := b.next_sibling() or { panic('no next') }
	assert next.text() == 'C'
}

fn test_element_no_parent_for_body() {
	doc := parse('<html><body></body></html>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	parent := body.parent() or { panic('no parent') }
	assert parent.local_name() == 'html'
}

fn test_element_child_nodes_includes_text() {
	doc := parse('<div>text<p>elem</p>more</div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	div := body.children()[0]
	nodes := div.child_nodes()
	assert nodes.len >= 3
}
