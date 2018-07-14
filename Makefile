GO_SRC = ./wc-go/src/wc.go
GO_BIN = ./bin/wc-go

.PHONY: all
all: go

.PHONY: go
go: $(GO_BIN)

$(GO_BIN): $(GO_SRC)
	go build -o $(GO_BIN) $(GO_SRC)
