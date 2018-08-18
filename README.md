# concurrent-wc

This project is for comparing async and concurrency tools in different
languages by implementing a simple `wc -l`-style utility.

## spec

The `wc` utility should do the following:

1.  Display the number of lines for each regular file in the directory.
2.  Display the cumulative number of lines of all files in the directory.
3.  Optionally take a single command-line argument specifying a different
    directory.
4.  Sort the files in terms of number of lines, in descending order.

e.g.

```
$ ./bin/wc-go tmp
        11 tmp/big.txt
         1 tmp/small.txt
        12 [TOTAL]
```

## implementing

The suggested implementation involves "fanning out" asynchronous tasks to read
through each file in the directory and count the lines concurrently. The tasks
will need to be synchronized at the end in order to compile the results and sort
them for display.

As of commit [c89a50e](https://github.com/dan-f/concurrent-wc/commit/c89a50e20954d0ba32973a39ad660cf31c1b2bba), the go implementation is the reference implementation.

## adding a language implementation

The various `wc` implementations should be put in sub-directories of the
top-level directory named `wc-$LANGNAME`; the go implementation is located in
`wc-go`. The resulting executables should be placed in `bin/wc-$LANGNAME`; the
go executable is located at `bin/wc-go`.

## dependencies

Each language implementation has its own dependencies.

- `wc-go` requires [go](https://golang.org/doc/install)
- `wc-haskell` requires the [stack build tool](https://docs.haskellstack.org/en/stable/README/)
- `wc-node` requires [node](https://nodejs.org/en/)
- `wc-ocaml` requires [OCaml](https://ocaml.org/docs/install.html) as well as the `async` and `core` packages
- `wc-python` requires [python3](https://www.python.org/getit/)
- `wc-ruby` requires [ruby](https://www.ruby-lang.org/en/downloads/)
- `wc-rust` requires [cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
- `wc-julia` requires [Julia 1.0](https://julialang.org/downloads/)

## building

Just run `make` from the project root. Or if you want to build a particular language implementation, run e.g. `make go` or `make rust`.

## contributors

Thanks to the following folks!

- Daniel Friedman <mailto:dfriedman58@gmail.com>
- Nicolas Hahn <mailto:nicolas@stonespring.org>
- Max Bittman <mailto:maxb.personal@gmail.com>
- Henry Stanley <mailto:henry@henrystanley.com>
