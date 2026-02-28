import vsoup
import os
import time

// Mirrors lexbor's benchmarks/lexbor/selectors/selectors.c exactly:
// - Same HTML (average.html)
// - Same 10 selectors
// - Same methodology: 5 iterations × 10,000 reps, mean time in seconds
// - Only lxb_selectors_find() is timed (setup outside timing) for the "raw" mode
//
// Two modes reported:
//   "raw"  — calls C bindings directly (apples-to-apples with native C)
//   "api"  — calls vsoup public API (includes per-call parser create/destroy overhead)

// Re-declare C types and functions needed for raw benchmark
// (the vsoup module declares them privately)

#flag -DLEXBOR_STATIC
#flag -I @VMODROOT/lexbor/source
#include "lexbor/html/html.h"
#include "lexbor/css/css.h"
#include "lexbor/selectors/selectors.h"

@[typedef]
struct C.lxb_html_document_t {}

@[typedef]
struct C.lxb_dom_node_t {}

@[typedef]
struct C.lxb_css_parser_t {}

@[typedef]
struct C.lxb_css_selector_list_t {}

@[typedef]
struct C.lxb_selectors_t {}

fn C.lxb_html_document_create() &C.lxb_html_document_t
fn C.lxb_html_document_parse(doc &C.lxb_html_document_t, html &u8, size usize) u32
fn C.lxb_html_document_destroy(doc &C.lxb_html_document_t) &C.lxb_html_document_t
fn C.lxb_css_parser_create() &C.lxb_css_parser_t
fn C.lxb_css_parser_init(parser &C.lxb_css_parser_t, tkz voidptr) u32
fn C.lxb_css_parser_destroy(parser &C.lxb_css_parser_t, self_destroy bool) &C.lxb_css_parser_t
fn C.lxb_css_selectors_parse(parser &C.lxb_css_parser_t, data &u8, length usize) &C.lxb_css_selector_list_t
fn C.lxb_css_selector_list_destroy_memory(list &C.lxb_css_selector_list_t)
fn C.lxb_selectors_create() &C.lxb_selectors_t
fn C.lxb_selectors_init(selectors &C.lxb_selectors_t) u32
fn C.lxb_selectors_destroy(selectors &C.lxb_selectors_t, self_destroy bool) &C.lxb_selectors_t
fn C.lxb_selectors_find(selectors &C.lxb_selectors_t, root &C.lxb_dom_node_t, list &C.lxb_css_selector_list_t, cb voidptr, ctx voidptr) u32
fn C.lxb_selectors_opt_set_noi(selectors &C.lxb_selectors_t, opt int)

const bm_selectors = [
	'div',
	'div span',
	'p ~ p',
	'p + p',
	'div > p',
	'div > div',
	'div p:not(#p-5) a',
	'div:has(a) a',
	'div p:nth-child(n+2)',
	'div p:nth-child(n+2 of div > p)',
]

const bm_iterations = 5
const bm_repeat = 10000

fn bm_find_callback(node &C.lxb_dom_node_t, spec u32, ctx voidptr) u32 {
	mut count := unsafe { &int(ctx) }
	unsafe {
		*count = *count + 1
	}
	return 0
}

fn bench_raw(html_data string) {
	println('=== Raw C bindings (apples-to-apples with lexbor native C) ===')
	println('')

	h_ptr := html_data.str
	h_len := usize(html_data.len)

	for sel in bm_selectors {
		// Setup outside timing: parse HTML, create parser+selectors, parse CSS
		document := C.lxb_html_document_create()
		C.lxb_html_document_parse(document, h_ptr, h_len)

		css_parser := C.lxb_css_parser_create()
		C.lxb_css_parser_init(css_parser, unsafe { nil })

		sel_engine := C.lxb_selectors_create()
		C.lxb_selectors_init(sel_engine)
		C.lxb_selectors_opt_set_noi(sel_engine, 1 << 2) // LXB_SELECTORS_OPT_MATCH_FIRST

		s_ptr := sel.str
		s_len := usize(sel.len)
		list := C.lxb_css_selectors_parse(css_parser, s_ptr, s_len)

		body := unsafe { &C.lxb_dom_node_t(document) }

		// Timed section: 5 iterations × 10,000 reps, report mean
		mut mean := f64(0)
		for _ in 0 .. bm_iterations {
			mut count := 0
			sw := time.new_stopwatch()
			for _ in 0 .. bm_repeat {
				C.lxb_selectors_find(sel_engine, body, list, voidptr(bm_find_callback),
					voidptr(&count))
			}
			elapsed := sw.elapsed()
			mean += f64(elapsed) / f64(time.second)
		}
		mean /= f64(bm_iterations)

		println('Run: ${sel}; Repeat: ${bm_repeat}; Result: ${mean:.5f} sec')

		// Cleanup
		C.lxb_selectors_destroy(sel_engine, true)
		C.lxb_css_parser_destroy(css_parser, true)
		C.lxb_css_selector_list_destroy_memory(list)
		C.lxb_html_document_destroy(document)
	}
}

fn bench_api(html_data string) {
	println('')
	println('=== vsoup public API (full pipeline per call) ===')
	println('')

	doc := vsoup.parse(html_data) or {
		eprintln('Failed to parse HTML')
		return
	}
	defer { doc.free() }

	for sel in bm_selectors {
		mut mean := f64(0)
		for _ in 0 .. bm_iterations {
			sw := time.new_stopwatch()
			for _ in 0 .. bm_repeat {
				_ = doc.@select(sel)
			}
			elapsed := sw.elapsed()
			mean += f64(elapsed) / f64(time.second)
		}
		mean /= f64(bm_iterations)

		println('Run: ${sel}; Repeat: ${bm_repeat}; Result: ${mean:.5f} sec')
	}
}

fn main() {
	html_path := if os.args.len > 1 {
		os.args[1]
	} else {
		'lexbor/benchmarks/lexbor/selectors/files/average.html'
	}

	html_data := os.read_file(html_path) or {
		eprintln('Failed to read ${html_path}')
		return
	}

	println('vsoup vs lexbor selector benchmark')
	println('HTML: ${html_path} (${html_data.len} bytes)')
	println('Method: mean of ${bm_iterations} iterations × ${bm_repeat} reps')
	println('')

	bench_raw(html_data)
	bench_api(html_data)
}
