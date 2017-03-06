#!/bin/sh

mkdir -p build

# First we configure and build the native ocaml compiler so that we can use it
# to compile our ml script at the same version.
cd ocaml
make clean
./configure -no-native-compiler -no-debugger -no-curses -no-ocamldoc -no-graph
make world
cd ..

# Build the OCaml example file to byte code.
./ocaml/byterun/ocamlrun ./ocaml/ocamlc -o build/example example.ml -nostdlib -I ./ocaml/stdlib

# Next we configure ocaml for emscripten instead.
cd ocaml
make clean
emconfigure ./configure -cc emcc -no-pthread -no-native-compiler -no-debugger -no-curses -no-ocamldoc -no-graph

# TODO: Fix these aliasing hacks.
# Alias ar to use the llvm version since emscripten requires it but the OCaml
# make files doesn't pick up its override of the standard archive tool.
alias ar='llvm-ar'

## Next we will build the byte code interpreter using emscripten.
cd byterun
emmake make
# internal ranlib command failed try again.
emmake make

# Give the output a file extension so that emscripten can infer it.
mv ocamlrun ocamlrun.o

cd ../..

emcc -s WASM=1 -O2 ocaml/byterun/ocamlrun.o -o build/ocamlrun.js --preload-file build/example
