import vsoup

fn main() {
	html := '
	<html>
	<head><title>Example</title></head>
	<body>
		<div id="content" class="main">
			<h1>Welcome</h1>
			<p class="intro">This is a paragraph.</p>
			<ul>
				<li><a href="/one">Link One</a></li>
				<li><a href="/two">Link Two</a></li>
				<li><a href="/three">Link Three</a></li>
			</ul>
		</div>
	</body>
	</html>'

	// Parse HTML — returns Result type, handle errors with `or {}`
	doc := vsoup.parse(html) or {
		eprintln('Failed to parse: ${err}')
		return
	}
	// Always free the document when done — Elements become invalid after this
	defer { doc.free() }

	// Document info
	println('Title: ${doc.title()}')

	// Select by ID — returns Option, handle with `or {}`
	content := doc.select_first('#content') or {
		eprintln('No #content found')
		return
	}
	println('Content class: ${content.class_name()}')

	// Select all links — `@select` uses `@` because `select` is a V keyword
	links := doc.@select('a')
	println('Found ${links.len()} links:')
	for link in links.iter() {
		println('  ${link.text()} -> ${link.attr("href")}')
	}

	// CSS selectors with error handling
	intro := doc.select_first('p.intro') or {
		eprintln('No intro found')
		return
	}
	println('Intro: ${intro.text()}')

	// DOM manipulation
	content.set_attr('data-loaded', 'true')
	content.add_class('active')
	println('Updated classes: ${content.class_name()}')
	println('Has data-loaded: ${content.has_attr("data-loaded")}')

	// Append new content
	content.append('<footer>End of content</footer>')
	println('\nFinal HTML:')
	println(content.outer_html())
}
