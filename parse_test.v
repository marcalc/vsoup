module vsoup

fn test_parse_simple_html() {
	doc := parse('<html><body><p>Hello</p></body></html>')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	children := body.children()
	assert children.len == 1
	assert children[0].local_name() == 'p'
	assert children[0].text() == 'Hello'
}

fn test_parse_returns_title() {
	doc := parse('<html><head><title>My Title</title></head><body></body></html>')!
	defer { doc.free() }
	assert doc.title() == 'My Title'
}

fn test_parse_head_and_body() {
	doc := parse('<html><head></head><body><div>test</div></body></html>')!
	defer { doc.free() }
	head := doc.head() or { panic('no head') }
	assert head.local_name() == 'head'
	body := doc.body() or { panic('no body') }
	assert body.local_name() == 'body'
}

fn test_parse_file() {
	doc := parse_file('tests/testdata/simple.html')!
	defer { doc.free() }
	assert doc.title() == 'Test Page'
	body := doc.body() or { panic('no body') }
	children := body.children()
	assert children.len > 0
}

fn test_parse_malformed_html() {
	doc := parse('<div><p>unclosed<span>nested')!
	defer { doc.free() }
	body := doc.body() or { panic('no body') }
	assert body.children().len > 0
}

fn test_parse_empty_html() {
	doc := parse('')!
	defer { doc.free() }
	_ := doc.body() or { return }
}

fn test_document_html_serialization() {
	doc := parse('<html><body><p>Hello</p></body></html>')!
	defer { doc.free() }
	h := doc.html()
	assert h.contains('<p>Hello</p>')
}

fn test_document_pretty_html() {
	doc := parse('<html><body><p>Hello</p></body></html>')!
	defer { doc.free() }
	pretty := doc.pretty_html()
	assert pretty.contains('Hello')
	assert pretty.len > 0
}
