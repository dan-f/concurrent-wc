GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go
RUST_SRC_DIR = ./wc-rust/
RUST_SRC = ./wc-rust/src/main.rs
RUST_BIN = ./bin/wc-rust

HASKELL_SRC = ./wc-haskell/src/Lib.hs ./wc-haskell/app/Main.hs
HASKELL_BIN = ./bin/wc-haskell

PYTHON_SRC = ./wc-python/src/wc.py
PYTHON_BIN = ./bin/wc-python

.PHONY: all
all: go haskell rust python

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

$(RUST_BIN): $(RUST_SRC)
	cd $(RUST_SRC_DIR) && \
	cargo build --release && \
	cd ../ && \
	cp $(RUST_SRC_DIR)target/release/wc-rust $(RUST_BIN)

.PHONY: python
python: $(PYTHON_BIN)

$(PYTHON_BIN): $(PYTHON_SRC)
	cp $(PYTHON_SRC) $(PYTHON_BIN) && chmod u+x $(PYTHON_BIN)
