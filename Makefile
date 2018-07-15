GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go

HASKELL_SRC = ./wc-haskell/src/Lib.hs ./wc-haskell/app/Main.hs
HASKELL_BIN = ./bin/wc-haskell

.PHONY: all
all: go haskell

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
