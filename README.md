# vsoup

A fast, JSoup-inspired HTML5 parser and DOM manipulation library for [V](https://vlang.io), powered by [Lexbor](https://lexbor.com) v2.6.0.

## Features

- **HTML5 parsing** — full spec-compliant parsing via Lexbor
- **CSS selectors** — `select()`, `select_first()` with cached compiled selectors
- **DOM traversal** — `children()`, `parent()`, `next_sibling()`, etc.
- **DOM manipulation** — `set_attr()`, `add_class()`, `append()`, `remove()`, etc.
- **Serialization** — `html()`, `outer_html()`, `pretty_html()`
- **HTTP client** — JSoup-style `connect(url).get()` builder

## Quick Start

```v
import vsoup

doc := vsoup.parse('<div class="main"><p>Hello</p><a href="/link">World</a></div>')!
defer { doc.free() }

// CSS selectors
links := doc.@select('a[href]')
println(links.first()!.attr('href'))  // "/link"
println(links.first()!.text())        // "World"

// DOM traversal
body := doc.body()!
for child in body.children() {
    println(child.tag_name())
}

// DOM manipulation
mut div := doc.select_first('.main')!
div.set_attr('data-processed', 'true')
div.add_class('active')
div.append('<span>New content</span>')
println(doc.html())
```

## Installation

### Via VPM

```sh
v install marcalc.vsoup
```

### From source

```sh
git clone https://github.com/marcalc/vsoup.git
cd vsoup
make test
```

[Lexbor](https://lexbor.com) v2.6.0 is vendored and compiled directly by V — no CMake or separate build step required.

## API Reference

### Parsing

```v
doc := vsoup.parse(html_string)!          // parse HTML string
doc := vsoup.parse_file('page.html')!     // parse from file
doc := vsoup.connect('https://example.com').get()!  // fetch & parse
defer { doc.free() }
```

### Document

| Method | Returns | Description |
|--------|---------|-------------|
| `doc.body()` | `?Element` | The `<body>` element |
| `doc.head()` | `?Element` | The `<head>` element |
| `doc.title()` | `string` | Document title text |
| `doc.@select(css)` | `Elements` | All matching elements (`@` escapes V keyword) |
| `doc.select_first(css)` | `?Element` | First matching element |
| `doc.html()` | `string` | Serialized HTML |
| `doc.pretty_html()` | `string` | Pretty-printed HTML |
| `doc.free()` | | Free all resources |

### Element

| Method | Returns | Description |
|--------|---------|-------------|
| `e.tag_name()` | `string` | Uppercase tag name (e.g. `"DIV"`) |
| `e.local_name()` | `string` | Lowercase tag name (e.g. `"div"`) |
| `e.id()` | `string` | The `id` attribute |
| `e.class_name()` | `string` | The `class` attribute |
| `e.class_names()` | `[]string` | Individual class names |
| `e.has_class(name)` | `bool` | Check for a class |
| `e.attr(key)` | `string` | Attribute value |
| `e.has_attr(key)` | `bool` | Check attribute existence |
| `e.attributes()` | `map[string]string` | All attributes |
| `e.text()` | `string` | Text content (recursive) |
| `e.html()` | `string` | Inner HTML |
| `e.outer_html()` | `string` | Outer HTML |
| `e.@select(css)` | `Elements` | CSS select descendants (`@` escapes V keyword) |
| `e.select_first(css)` | `?Element` | First matching descendant |
| `e.parent()` | `?Element` | Parent element |
| `e.children()` | `[]Element` | Child elements |
| `e.first_child()` | `?Element` | First child element |
| `e.next_sibling()` | `?Element` | Next sibling element |
| `e.prev_sibling()` | `?Element` | Previous sibling element |
| `e.set_attr(k, v)` | | Set attribute |
| `e.remove_attr(k)` | | Remove attribute |
| `e.add_class(name)` | | Add a class |
| `e.remove_class(name)` | | Remove a class |
| `e.append(html)` | | Append child HTML |
| `e.prepend(html)` | | Prepend child HTML |
| `e.remove()` | | Remove from DOM |
| `e.empty()` | | Remove all children |
| `e.set_text(text)` | | Set text content |

### Elements

| Method | Returns | Description |
|--------|---------|-------------|
| `es.len()` | `int` | Number of elements |
| `es.first()` | `?Element` | First element |
| `es.last()` | `?Element` | Last element |
| `es.at(i)` | `?Element` | Element at index |
| `es.text()` | `string` | Combined text of all |
| `es.attr(key)` | `string` | First matching attr |
| `es.each_attr(key)` | `[]string` | Attr from each element |
| `es.@select(css)` | `Elements` | Sub-select across all |
| `es.iter()` | `[]Element` | For use in `for` loops |

### HTTP Client

```v
doc := vsoup.connect('https://example.com')
    .user_agent('vsoup/0.1')
    .header('Accept', 'text/html')
    .cookie('session', 'abc123')
    .get()!
defer { doc.free() }
```

## Benchmarks

Selector benchmarks against native Lexbor C and jsoup (Java), using the same HTML fixture and methodology: **5 iterations x 10,000 repetitions, mean time in seconds.**

Lexbor v2.6.0 | jsoup 1.22.2 | macOS ARM64

| Selector | Lexbor C | vsoup (V) | jsoup (Java) |
|---|---|---|---|
| `div` | 0.00418 | 0.00622 (1.5x) | 0.01596 (3.8x) |
| `div span` | 0.00554 | 0.00715 (1.3x) | 0.02966 (5.4x) |
| `p ~ p` | 0.00503 | 0.00652 (1.3x) | 0.02262 (4.5x) |
| `p + p` | 0.00496 | 0.00660 (1.3x) | 0.01900 (3.8x) |
| `div > p` | 0.00507 | 0.00692 (1.4x) | 0.01434 (2.8x) |
| `div > div` | 0.00512 | 0.00731 (1.4x) | 0.01414 (2.8x) |
| `div p:not(#p-5) a` | 0.00785 | 0.00953 (1.2x) | 0.03763 (4.8x) |
| `div:has(a) a` | 0.00726 | 0.00905 (1.2x) | 0.02558 (3.5x) |
| `div p:nth-child(n+2)` | 0.00643 | 0.00799 (1.2x) | 0.02950 (4.6x) |
| `div p:nth-child(n+2 of div > p)` | 0.01364 | 0.01685 (1.2x) | n/a |

**vsoup is 1.2-1.5x native Lexbor C** (thin wrapper overhead) and **2-4x faster than jsoup**.

The remaining overhead vs raw C is from the V function call layer and result collection into V arrays. The actual `lxb_selectors_find` is called identically — compiled selectors are cached and reused across queries.

### Running benchmarks

```sh
make bench-selectors  # vsoup vs lexbor (raw C bindings + public API)
make bench-parse      # vsoup microbenchmarks (parse, traverse, select, serialize, manipulate)
make bench-jsoup      # jsoup comparison (downloads jar automatically)
```

## Thread Safety

vsoup is **not thread-safe**. Each `Document` (and its associated `Element` values) should be used from a single thread. If you need to parse multiple documents concurrently, create a separate `Document` per thread.

## Memory Management

`Document` owns the underlying Lexbor C memory and **must** be freed with `free()`:

```v
doc := vsoup.parse(html)!
defer { doc.free() }  // always pair with defer
```

`Element` is a lightweight, non-owning view (24 bytes) into the document's DOM tree. Elements do not need to be freed individually, but they **must not be used after their parent Document is freed** — doing so is undefined behavior.

## Error Handling

Parsing and HTTP operations return V `Result` types (`!`). Use `or {}` blocks to handle errors:

```v
// Parsing errors
doc := vsoup.parse(html) or {
    eprintln('Parse failed: ${err}')
    return
}
defer { doc.free() }

// Selector queries return Option types
elem := doc.select_first('.missing') or {
    println('Element not found')
    return
}

// HTTP errors
doc2 := vsoup.connect('https://example.com').get() or {
    eprintln('Fetch failed: ${err}')
    return
}
defer { doc2.free() }
```

## Architecture

```
vsoup
├── bindings.v      # C FFI declarations (lexbor)
├── lexbor_*.c      # Per-module unity builds — V compiles lexbor directly
├── helpers.v       # C↔V conversion, serialization, selector cache
├── vsoup.v         # parse(), parse_file(), connect()
├── document.v      # Document struct
├── element.v       # Element struct (non-owning DOM node view)
├── elements.v      # Elements collection
├── node_type.v     # NodeType enum
├── connection.v    # HTTP client
├── c_shims.c/h     # Compatibility shims for lexbor v2.6.0
└── lexbor/         # Vendored lexbor v2.6.0 source
```

**Key design decisions:**
- `Element` is a lightweight, non-owning pointer wrapper (24 bytes) — freely copyable
- `Document` owns the C memory and must be freed with `free()`
- CSS selectors are compiled once and cached per-document for reuse
- All V strings are copies from C memory (no dangling pointers)

## Acknowledgements

- [Lexbor](https://lexbor.com) — the fast, spec-compliant HTML5 engine that powers vsoup's parsing and selector machinery. Created by [Alexander Borisov](https://github.com/nicktrandafil/lexbor).
- [jsoup](https://jsoup.org) — the excellent Java HTML parser whose clean API design inspired vsoup's interface. Created by [Jonathan Hedley](https://jhy.io).

## License

MIT
