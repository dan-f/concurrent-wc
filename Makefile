GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go
RUST_SRC_DIR = ./wc-rust/
RUST_SRC = ./wc-rust/src/main.rs
RUST_BIN = ./bin/wc-rust

.PHONY: all
all: go rust

.PHONY: go rust
go: $(GO_BIN)

$(GO_BIN): $(GO_SRC)
	go build -o $(GO_BIN) $(GO_SRC)

rust: $(RUST_BIN)

$(RUST_BIN): $(RUST_SRC)
	cd $(RUST_SRC_DIR) && cargo build --release && cd ../ && cp $(RUST_SRC_DIR)target/release/wc-rust $(RUST_BIN)
