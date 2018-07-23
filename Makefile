GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go

RUST_SRC_DIR = ./wc-rust/
RUST_BIN = ./bin/wc-rust

HASKELL_SRC = ./wc-haskell/src/Lib.hs ./wc-haskell/app/Main.hs
HASKELL_BIN = ./bin/wc-haskell

RUBY_SRC = ./wc-ruby/lib/binstub
RUBY_BIN = ./bin/wc-ruby

NODE_SRC = ./wc-node/bin/wc.js
NODE_BIN = ./bin/wc-node

.PHONY: all
all: go haskell rust ruby node

.PHONY: rust
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

.PHONY: ruby
ruby: $(RUBY_BIN)

$(RUBY_BIN): $(RUBY_SRC)
	cp $(RUBY_SRC) $(RUBY_BIN) && chmod +x $(RUBY_BIN)

.PHONY: node
node: $(NODE_BIN)

$(NODE_BIN): $(NODE_SRC)
	cp $(NODE_SRC) $(NODE_BIN) && chmod u+x $(NODE_BIN)
