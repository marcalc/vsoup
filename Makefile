.PHONY: setup test bench bench-selectors bench-parse bench-jsoup example clean install

# Build lexbor static library
setup:
	bash setup.sh

# Run all tests
test:
	v test .

# Run all benchmarks
bench: bench-selectors bench-parse

# Selector benchmarks (vsoup vs lexbor C)
bench-selectors:
	v -prod run benchmarks/bench_selectors_compare.v

# Parse/traverse/serialize microbenchmarks
bench-parse:
	v -prod run benchmarks/bench_parse.v

# jsoup comparison benchmark (downloads jar automatically)
bench-jsoup:
	bash benchmarks/bench_jsoup.sh

# Run the basic example
example:
	v -path "$(CURDIR)/..|@vlib|@vmodules" run examples/basic.v

# Clean lexbor build artifacts
clean:
	rm -rf lexbor/build

# Symlink into V modules
install:
	ln -sf $(CURDIR) ~/.vmodules/vsoup
