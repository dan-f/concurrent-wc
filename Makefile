GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go
RUST_SRC_DIR = ./wc-rust/
RUST_SRC = ./wc-rust/src/main.rs
RUST_BIN = ./bin/wc-rust

HASKELL_SRC = ./wc-haskell/src/Lib.hs ./wc-haskell/app/Main.hs
HASKELL_BIN = ./bin/wc-haskell

.PHONY: all
all: go haskell rust

.PHONY: go rust
go: $(GO_BIN)

$(GO_BIN): $(GO_SRC)
	go build -o $(GO_BIN) $(GO_SRC)

.PHONY: haskell
haskell: $(HASKELL_BIN)

$(HASKELL_BIN): $(HASKELL_SRC)
	cd wc-haskell && \
		stack build && \
		cp ./`stack path --dist-dir`/build/wc-haskell-exe/wc-haskell-exe ../$(HASKELL_BIN)

rust: $(RUST_BIN)

$(RUST_BIN): $(RUST_SRC)
	cd $(RUST_SRC_DIR) && \
	cargo build --release && \
	cd ../ && \
	cp $(RUST_SRC_DIR)target/release/wc-rust $(RUST_BIN)
