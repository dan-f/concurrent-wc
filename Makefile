GO_SRC = go/src/wc.go
GO_BIN = bin/go/wc

.PHONY: all
all: go

.PHONY: go
go: $(GO_BIN)

$(GO_BIN): $(GO_SRC)
	go build -o $(GO_BIN) $(GO_SRC)
