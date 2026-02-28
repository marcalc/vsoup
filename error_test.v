module vsoup

fn test_invalid_css_selector_returns_empty() {
	doc := parse('<div><p>Hello</p></div>')!
	defer { doc.free() }
	result := doc.@select('{{invalid}}')
	assert result.len() == 0
}

fn test_invalid_css_selector_on_element_returns_empty() {
	doc := parse('<div><p>Hello</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	result := body.@select('[[[bad')
	assert result.len() == 0
}

fn test_select_first_no_match_returns_none() {
	doc := parse('<div><p>Hello</p></div>')!
	defer { doc.free() }
	elem := doc.select_first('.nonexistent') or { return }
	// Should not reach here
	assert false
}

fn test_select_first_invalid_selector_returns_none() {
	doc := parse('<div><p>Hello</p></div>')!
	defer { doc.free() }
	elem := doc.select_first('{{invalid}}') or { return }
	assert false
}

fn test_parse_empty_string_succeeds() {
	doc := parse('')!
	defer { doc.free() }
	// Should not crash; body may or may not exist
	html := doc.html()
	assert html.len >= 0
}

fn test_parse_malformed_html_recovers() {
	doc := parse('<div><p>unclosed<span>nested')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	// Lexbor should recover and produce a valid tree
	assert body.children().len > 0
}

fn test_parse_only_text() {
	doc := parse('just plain text')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	assert body.text().contains('just plain text')
}

fn test_get_element_by_id_no_match() {
	doc := parse('<div><p>Hello</p></div>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	elem := body.get_element_by_id('nonexistent') or { return }
	assert false
}
