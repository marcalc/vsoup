module vsoup

import net.http

// Response holds the result of an HTTP request.
pub struct Response {
pub:
	status_code int              // HTTP status code (e.g. 200, 404)
	body        string           // Response body as a string
	headers     map[string]string // Response headers (lowercase keys)
}

// Connection provides a builder-pattern HTTP client for fetching and parsing HTML.
// Use `vsoup.connect(url)` to create one, then chain builder methods:
//   `vsoup.connect(url).user_agent('bot').timeout(5000).get()!`
pub struct Connection {
mut:
	target_url  string
	method      http.Method = .get
	user_agent_ string = 'vsoup/0.1'
	timeout_ms  int    = 30000
	headers_    map[string]string
	cookies_    map[string]string
	data_       map[string]string
}

// new_connection creates a Connection for the given URL.
fn new_connection(url string) Connection {
	return Connection{
		target_url: url
	}
}

// url sets the target URL.
// `unsafe { c }` returns a reference to the receiver for method chaining — safe because
// the Connection is stack-local and outlives the chain.
pub fn (mut c Connection) url(url string) &Connection {
	c.target_url = url
	return unsafe { c }
}

// user_agent sets the User-Agent header.
pub fn (mut c Connection) user_agent(ua string) &Connection {
	c.user_agent_ = ua
	return unsafe { c }
}

// timeout sets the request timeout in milliseconds.
pub fn (mut c Connection) timeout(ms int) &Connection {
	c.timeout_ms = ms
	return unsafe { c }
}

// header adds a custom header.
pub fn (mut c Connection) header(key string, val string) &Connection {
	c.headers_[key] = val
	return unsafe { c }
}

// cookie adds a cookie.
pub fn (mut c Connection) cookie(key string, val string) &Connection {
	c.cookies_[key] = val
	return unsafe { c }
}

// data adds a form data parameter (for POST requests).
pub fn (mut c Connection) data(key string, val string) &Connection {
	c.data_[key] = val
	return unsafe { c }
}

// get performs an HTTP GET request and parses the response as HTML.
pub fn (c Connection) get() !Document {
	resp := c.do_execute(.get)!
	return parse(resp.body)
}

// post performs an HTTP POST request and parses the response as HTML.
pub fn (c Connection) post() !Document {
	resp := c.do_execute(.post)!
	return parse(resp.body)
}

// execute performs the HTTP request and returns the raw Response.
pub fn (c Connection) execute() !Response {
	return c.do_execute(c.method)
}

fn (c Connection) do_execute(method http.Method) !Response {
	mut config := http.FetchConfig{
		url: c.target_url
		method: method
		verbose: false
	}

	// Set headers
	mut hdrs := http.new_header()
	hdrs.add(.user_agent, c.user_agent_)
	for key, val in c.headers_ {
		hdrs.add_custom(key, val) or { return error('failed to set header: ${err}') }
	}

	// Set cookies
	if c.cookies_.len > 0 {
		mut cookie_parts := []string{cap: c.cookies_.len}
		for k, v in c.cookies_ {
			cookie_parts << '${k}=${v}'
		}
		hdrs.add_custom('Cookie', cookie_parts.join('; ')) or {
			return error('failed to set cookie header: ${err}')
		}
	}
	config.header = hdrs

	// Set form data for POST
	if method == .post && c.data_.len > 0 {
		mut parts := []string{cap: c.data_.len}
		for k, v in c.data_ {
			parts << '${k}=${v}'
		}
		config.data = parts.join('&')
		hdrs.add(.content_type, 'application/x-www-form-urlencoded')
	}

	resp := http.fetch(config) or { return error('HTTP request failed: ${err}') }

	mut resp_headers := map[string]string{}
	for key in resp.header.keys() {
		val := resp.header.custom_values(key.str())
		if val.len > 0 {
			resp_headers[key.str()] = val[0]
		}
	}

	return Response{
		status_code: resp.status_code
		body: resp.body
		headers: resp_headers
	}
}
