GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go

RUST_SRC_DIR = ./wc-rust/
RUST_BIN = ./bin/wc-rust

HASKELL_SRC = ./wc-haskell/src/Lib.hs ./wc-haskell/app/Main.hs
HASKELL_BIN = ./bin/wc-haskell

RUBY_SRC = ./wc-ruby/lib/binstub
RUBY_BIN = ./bin/wc-ruby

PYTHON_SRC = ./wc-python/src/wc.py
PYTHON_BIN = ./bin/wc-python

OCAML_SRC = ./wc-ocaml/*.ml ./wc-ocaml/*.mli
OCAML_BIN = ./bin/wc-ocaml

NODE_SRC = ./wc-node/src/wc.js
NODE_BIN = ./bin/wc-node

BASH_SRC = ./wc-bash/wc-bash
BASH_BIN = ./bin/wc-bash

C_SRC = ./wc-c/wc
C_BIN = ./bin/wc-c

.PHONY: all
all: go haskell rust ruby python ocaml node bash c

.PHONY: go
go: $(GO_BIN)

$(GO_BIN): $(GO_SRC)
	go build -o $(GO_BIN) $(GO_SRC)

.PHONY: haskell
haskell: $(HASKELL_BIN)

$(HASKELL_BIN): $(HASKELL_SRC)
	cd wc-haskell && \
	stack build && \
	cp ./`stack path --dist-dir`/build/wc-haskell-exe/wc-haskell-exe ../$(HASKELL_BIN)

.PHONY: rust
rust: $(RUST_BIN)

$(RUST_BIN): $(RUST_SRC_DIR)
	cd $(RUST_SRC_DIR) && \
	cargo build --release && \
	cd ../ && \
	cp $(RUST_SRC_DIR)target/release/wc $(RUST_BIN)

.PHONY: python
python: $(PYTHON_BIN)

$(PYTHON_BIN): $(PYTHON_SRC)
	cp $(PYTHON_SRC) $(PYTHON_BIN) && chmod u+x $(PYTHON_BIN)

.PHONY: ruby
ruby: $(RUBY_BIN)

$(RUBY_BIN): $(RUBY_SRC)
	cp $(RUBY_SRC) $(RUBY_BIN) && chmod +x $(RUBY_BIN)

.PHONY: ocaml
ocaml: $(OCAML_BIN)

$(OCAML_BIN): $(OCAML_SRC)
	cd wc-ocaml && \
	corebuild wc_ocaml.native -pkgs str,async && \
	cp wc_ocaml.native ../$(OCAML_BIN)

.PHONY: node
node: $(NODE_BIN)

$(NODE_BIN): $(NODE_SRC)
	printf "#!/bin/sh\nnode --no-warnings $(NODE_SRC) $$%d\n" 1 > $(NODE_BIN) && chmod u+x $(NODE_BIN)

.PHONY: bash
bash: $(BASH_BIN)

$(BASH_BIN): $(BASH_SRC)
	cp $(BASH_SRC) $(BASH_BIN) && chmod u+x $(BASH_BIN)

.PHONY: c
c:
	make -C wc-c/src
