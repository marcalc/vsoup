module vsoup

fn test_connection_builder() {
	mut conn := connect('https://example.com')
	conn.user_agent('test-agent')
	conn.timeout(5000)
	conn.header('Accept', 'text/html')
	conn.cookie('session', 'abc123')
}

fn test_connection_builder_values() {
	mut conn := connect('https://example.com')
	conn.user_agent('test-agent')
	conn.timeout(5000)
	conn.header('Accept', 'text/html')
	conn.cookie('session', 'abc123')
	assert conn.target_url == 'https://example.com'
	assert conn.user_agent_ == 'test-agent'
	assert conn.timeout_ms == 5000
	assert conn.headers_['Accept'] == 'text/html'
	assert conn.cookies_['session'] == 'abc123'
}

fn test_connection_builder_data() {
	mut conn := connect('https://httpbin.org/post')
	conn.data('username', 'test')
	conn.data('password', 'secret')
	assert conn.data_['username'] == 'test'
	assert conn.data_['password'] == 'secret'
}

fn test_connection_builder_url_override() {
	mut conn := connect('https://example.com')
	conn.url('https://other.com')
	assert conn.target_url == 'https://other.com'
}

fn test_connection_get() {
	doc := connect('https://example.com').get() or {
		eprintln('Skipping connection test: ${err}')
		return
	}
	defer { doc.free() }
	title := doc.title()
	assert title.len > 0
}
