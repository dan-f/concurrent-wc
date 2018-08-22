#!/bin/bash
stack clean
stack build --profile
rm wc-haskell-exe.eventlog wc-haskell-exe.dashs wc-haskell-exe.prof
stack exec -- wc-haskell-exe ../tmp +RTS -l # generate eventlog
stack exec -- wc-haskell-exe ../tmp +RTS -p # generate profile
stack exec -- wc-haskell-exe ../tmp +RTS -s 2> wc-haskell-exe.dashs
stack exec -- wc-haskell-exe ../tmp > wc-haskell-exe.output
threadscope wc-haskell-exe.eventlog
