module vsoup

fn test_set_attr() {
	doc := parse('<div><p>test</p></div>')!
	defer { doc.free() }
	p := doc.select_first('p') or { panic('no p') }
	p.set_attr('data-x', '42')
	assert p.attr('data-x') == '42'
	assert p.has_attr('data-x')
}

fn test_remove_attr() {
	doc := parse('<div data-x="1">test</div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	assert div.has_attr('data-x')
	div.remove_attr('data-x')
	assert !div.has_attr('data-x')
}

fn test_add_class() {
	doc := parse('<div class="foo">test</div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.add_class('bar')
	assert div.has_class('foo')
	assert div.has_class('bar')
}

fn test_add_class_no_duplicate() {
	doc := parse('<div class="foo">test</div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.add_class('foo')
	assert div.class_name() == 'foo'
}

fn test_add_class_to_empty() {
	doc := parse('<div>test</div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.add_class('new')
	assert div.has_class('new')
	assert div.class_name() == 'new'
}

fn test_remove_class() {
	doc := parse('<div class="foo bar baz">test</div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.remove_class('bar')
	assert div.has_class('foo')
	assert !div.has_class('bar')
	assert div.has_class('baz')
}

fn test_remove_last_class() {
	doc := parse('<div class="only">test</div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.remove_class('only')
	assert !div.has_attr('class')
}

fn test_append_html() {
	doc := parse('<div id="main"><p>existing</p></div>')!
	defer { doc.free() }
	div := doc.select_first('#main') or { panic('no #main') }
	div.append('<span>New</span>')
	inner := div.html()
	assert inner.contains('<p>existing</p>')
	assert inner.contains('<span>New</span>')
}

fn test_prepend_html() {
	doc := parse('<div id="main"><p>existing</p></div>')!
	defer { doc.free() }
	div := doc.select_first('#main') or { panic('no #main') }
	div.prepend('<span>First</span>')
	inner := div.html()
	span_pos := inner.index('<span>First</span>') or { -1 }
	p_pos := inner.index('<p>existing</p>') or { -1 }
	assert span_pos >= 0
	assert p_pos >= 0
	assert span_pos < p_pos
}

fn test_remove_element() {
	doc := parse('<div><p>keep</p><p>remove</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	assert ps.len() == 2
	second := ps.at(1) or { panic('no second') }
	second.remove()
	ps_after := doc.@select('p')
	assert ps_after.len() == 1
	first := ps_after.first() or { panic('no first') }
	assert first.text() == 'keep'
}

fn test_empty_element() {
	doc := parse('<div><p>A</p><p>B</p></div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.empty()
	assert div.children().len == 0
	assert div.html() == ''
}

fn test_set_text() {
	doc := parse('<div><p>old</p></div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.set_text('new text')
	assert div.text() == 'new text'
	assert div.children().len == 0
}

fn test_elements_bulk_set_attr() {
	doc := parse('<div><p>A</p><p>B</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	ps.set_attr('data-marked', 'true')
	for p in ps.iter() {
		assert p.attr('data-marked') == 'true'
	}
}

fn test_elements_bulk_remove() {
	doc := parse('<div><p>A</p><p>B</p><span>C</span></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	ps.remove()
	remaining := doc.@select('p')
	assert remaining.len() == 0
	spans := doc.@select('span')
	assert spans.len() == 1
}

fn test_elements_bulk_add_class() {
	doc := parse('<div><p>A</p><p>B</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	ps.add_class('highlight')
	for p in ps.iter() {
		assert p.has_class('highlight')
	}
}

fn test_set_attr_updates_existing() {
	doc := parse('<div data-x="old">test</div>')!
	defer { doc.free() }
	div := doc.select_first('div') or { panic('no div') }
	div.set_attr('data-x', 'new')
	assert div.attr('data-x') == 'new'
}
