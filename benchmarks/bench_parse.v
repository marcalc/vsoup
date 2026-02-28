import vsoup
import benchmark

const simple_html = '<html><head><title>Test</title></head><body><div id="main" class="container"><h1>Hello World</h1><p class="intro">This is a test.</p><p class="content">More content here.</p></div></body></html>'

fn generate_large_html(n int) string {
	mut parts := []string{cap: n + 2}
	parts << '<html><body>'
	for i in 0 .. n {
		parts << '<div class="item" id="item-${i}"><p>Paragraph ${i}</p><a href="/link/${i}">Link ${i}</a><span data-value="${i}">Value</span></div>'
	}
	parts << '</body></html>'
	return parts.join('')
}

fn bench_parse_simple() {
	mut bm := benchmark.start()
	for _ in 0 .. 10000 {
		doc := vsoup.parse(simple_html) or { continue }
		doc.free()
	}
	bm.measure('parse simple HTML x10000')
}

fn bench_parse_large() {
	large_html := generate_large_html(1000)
	mut bm := benchmark.start()
	for _ in 0 .. 100 {
		doc := vsoup.parse(large_html) or { continue }
		doc.free()
	}
	bm.measure('parse large HTML (1000 divs) x100')
}

fn bench_dom_traversal() {
	large_html := generate_large_html(1000)
	doc := vsoup.parse(large_html) or { return }
	defer { doc.free() }

	mut bm := benchmark.start()
	for _ in 0 .. 1000 {
		body := doc.body() or { continue }
		for child in body.children() {
			_ = child.local_name()
			_ = child.id()
			_ = child.class_name()
			for gc in child.children() {
				_ = gc.text()
			}
		}
	}
	bm.measure('DOM traversal (1000 divs, read props) x1000')
}

fn bench_css_select() {
	large_html := generate_large_html(1000)
	doc := vsoup.parse(large_html) or { return }
	defer { doc.free() }

	mut bm := benchmark.start()
	for _ in 0 .. 1000 {
		_ = doc.@select('div.item')
	}
	bm.measure('CSS select "div.item" (1000 matches) x1000')
}

fn bench_css_select_first() {
	large_html := generate_large_html(1000)
	doc := vsoup.parse(large_html) or { return }
	defer { doc.free() }

	mut bm := benchmark.start()
	for _ in 0 .. 10000 {
		_ = doc.select_first('div.item')
	}
	bm.measure('CSS select_first "div.item" x10000')
}

fn bench_css_select_by_id() {
	large_html := generate_large_html(1000)
	doc := vsoup.parse(large_html) or { return }
	defer { doc.free() }

	mut bm := benchmark.start()
	for _ in 0 .. 10000 {
		_ = doc.select_first('#item-500')
	}
	bm.measure('CSS select_first "#item-500" x10000')
}

fn bench_serialization() {
	large_html := generate_large_html(100)
	doc := vsoup.parse(large_html) or { return }
	defer { doc.free() }

	mut bm := benchmark.start()
	for _ in 0 .. 1000 {
		_ = doc.html()
	}
	bm.measure('serialize HTML (100 divs) x1000')
}

fn bench_attributes() {
	large_html := generate_large_html(1000)
	doc := vsoup.parse(large_html) or { return }
	defer { doc.free() }

	items := doc.@select('div.item')
	mut bm := benchmark.start()
	for _ in 0 .. 100 {
		for item in items.iter() {
			_ = item.attr('id')
			_ = item.attr('class')
			_ = item.has_attr('data-x')
			_ = item.attributes()
		}
	}
	bm.measure('read attributes (1000 elements, 4 ops each) x100')
}

fn bench_manipulation() {
	mut bm := benchmark.start()
	for _ in 0 .. 1000 {
		doc := vsoup.parse('<div id="main"></div>') or { continue }
		div := doc.select_first('#main') or {
			doc.free()
			continue
		}
		for j in 0 .. 10 {
			div.append('<p class="item">Item ${j}</p>')
		}
		div.set_attr('data-count', '10')
		div.add_class('loaded')
		_ = div.html()
		doc.free()
	}
	bm.measure('manipulation (parse + 10 appends + attrs + serialize) x1000')
}

fn main() {
	println('vsoup benchmarks')
	println('================')
	println('')

	bench_parse_simple()
	bench_parse_large()
	bench_dom_traversal()
	bench_css_select()
	bench_css_select_first()
	bench_css_select_by_id()
	bench_serialization()
	bench_attributes()
	bench_manipulation()
}
