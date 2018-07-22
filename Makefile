GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go

RUST_SRC_DIR = ./wc-rust/
RUST_BIN = ./bin/wc-rust

HASKELL_SRC = ./wc-haskell/src/Lib.hs ./wc-haskell/app/Main.hs
HASKELL_BIN = ./bin/wc-haskell

NODE_SRC = ./wc-node/bin/wc.js
NODE_BIN = ./bin/wc-node

.PHONY: all
all: go haskell rust node

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

.PHONY: node
node: $(NODE_BIN)

$(NODE_BIN): $(NODE_SRC)
	cp $(NODE_SRC) $(NODE_BIN) && chmod u+x $(NODE_BIN)
