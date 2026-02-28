module vsoup

fn test_elements_len() {
	doc := parse('<div><p>A</p><p>B</p><p>C</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	assert ps.len() == 3
}

fn test_elements_first_last() {
	doc := parse('<div><p>A</p><p>B</p><p>C</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	first := ps.first() or { panic('no first') }
	assert first.text() == 'A'
	last := ps.last() or { panic('no last') }
	assert last.text() == 'C'
}

fn test_elements_at() {
	doc := parse('<div><p>A</p><p>B</p><p>C</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	a := ps.at(0) or { panic('no 0') }
	assert a.text() == 'A'
	b := ps.at(1) or { panic('no 1') }
	assert b.text() == 'B'
	c := ps.at(2) or { panic('no 2') }
	assert c.text() == 'C'
	_ := ps.at(3) or { return }
	assert false
}

fn test_elements_text() {
	doc := parse('<div><p>Hello</p><p>World</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	text := ps.text()
	assert text.contains('Hello')
	assert text.contains('World')
}

fn test_elements_attr() {
	doc := parse('<div><a href="/a">A</a><a href="/b">B</a></div>')!
	defer { doc.free() }
	links := doc.@select('a')
	assert links.attr('href') == '/a'
}

fn test_elements_each_attr() {
	doc := parse('<div><a href="/a">A</a><a href="/b">B</a></div>')!
	defer { doc.free() }
	links := doc.@select('a')
	hrefs := links.each_attr('href')
	assert hrefs == ['/a', '/b']
}

fn test_elements_sub_select() {
	doc := parse('<div><ul><li>A</li></ul><ul><li>B</li></ul></div>')!
	defer { doc.free() }
	uls := doc.@select('ul')
	assert uls.len() == 2
	lis := uls.@select('li')
	assert lis.len() == 2
}

fn test_elements_iter() {
	doc := parse('<div><p>A</p><p>B</p></div>')!
	defer { doc.free() }
	ps := doc.@select('p')
	mut texts := []string{}
	for p in ps.iter() {
		texts << p.text()
	}
	assert texts == ['A', 'B']
}

fn test_elements_is_empty() {
	doc := parse('<div></div>')!
	defer { doc.free() }
	result := doc.@select('p')
	assert result.is_empty()
}
