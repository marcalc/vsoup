module vsoup

fn test_select_by_tag() {
	doc := parse('<div><p>A</p><p>B</p><span>C</span></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	assert ps.len() == 2
}

fn test_select_by_id() {
	doc := parse('<div id="main"><p>text</p></div>')!
	defer { doc.free() }
	result := doc.@select('#main')
	assert result.len() == 1
	first := result.first() or { panic('no first') }
	assert first.id() == 'main'
}

fn test_select_by_class() {
	doc := parse('<div><p class="a">X</p><p class="b">Y</p></div>')!
	defer { doc.free() }
	result := doc.@select('.a')
	assert result.len() == 1
	first := result.first() or { panic('no first') }
	assert first.text() == 'X'
}

fn test_select_by_attribute() {
	doc := parse('<div id="c"><a href="/z">Z</a><span>no link</span></div>')!
	defer { doc.free() }
	links := doc.@select('a[href]')
	assert links.len() == 1
	first := links.first() or { panic('no first') }
	assert first.attr('href') == '/z'
}

fn test_select_first() {
	doc := parse('<div><p class="a">X</p><p class="b">Y</p></div>')!
	defer { doc.free() }
	first := doc.select_first('p') or { panic('no match') }
	assert first.text() == 'X'
}

fn test_select_first_with_class() {
	doc := parse('<div><p class="a">X</p><p class="b">Y</p></div>')!
	defer { doc.free() }
	p := doc.select_first('p.b') or { panic('no match') }
	assert p.text() == 'Y'
}

fn test_select_descendant() {
	doc := parse('<div><ul><li>One</li><li>Two</li></ul></div>')!
	defer { doc.free() }
	items := doc.@select('div li')
	assert items.len() == 2
}

fn test_select_from_element() {
	doc := parse('<div id="a"><p>1</p></div><div id="b"><p>2</p></div>')!
	defer { doc.free() }
	div_b := doc.select_first('#b') or { panic('no #b') }
	ps := div_b.@select('p')
	assert ps.len() == 1
	first := ps.first() or { panic('no first') }
	assert first.text() == '2'
}

fn test_select_no_match() {
	doc := parse('<div><p>test</p></div>')!
	defer { doc.free() }
	result := doc.@select('.nonexistent')
	assert result.len() == 0
	assert result.is_empty()
}

fn test_select_complex_selector() {
	doc := parse_file('tests/testdata/selectors.html')!
	defer { doc.free() }

	items := doc.@select('li.item')
	assert items.len() == 3

	active := doc.select_first('li.active') or { panic('no active') }
	assert active.text() == 'One'

	footer_links := doc.@select('footer a')
	assert footer_links.len() == 2
}

fn test_select_attribute_value() {
	doc := parse_file('tests/testdata/selectors.html')!
	defer { doc.free() }

	span := doc.select_first('span[data-value="42"]') or { panic('no match') }
	assert span.text() == 'Deep'
}

fn test_select_multiple_selectors() {
	doc := parse('<div><p>P</p><span>S</span><a>A</a></div>')!
	defer { doc.free() }
	result := doc.@select('p, span')
	assert result.len() == 2
}

fn test_get_element_by_id() {
	doc := parse('<div><p id="target">Found</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	el := body.get_element_by_id('target') or { panic('not found') }
	assert el.text() == 'Found'
}

fn test_get_elements_by_tag() {
	doc := parse('<div><p>A</p><p>B</p><span>C</span></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	ps := body.get_elements_by_tag('p')
	assert ps.len() == 2
}

fn test_get_elements_by_class() {
	doc := parse('<div><p class="x">A</p><p class="x">B</p><p class="y">C</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	xs := body.get_elements_by_class('x')
	assert xs.len() == 2
}
