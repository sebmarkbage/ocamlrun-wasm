# OCamlrun WebAssembly

This is a build script for building the OCaml bytecode interpreter for WebAssembly using emscripten.

## Why a VM in a VM?

### Why not compile OCaml code straight to WebAssembly?

Currently it is not that easy because AFAIK there is no high fidelity maintained LLVM output target nor any WebAssembly compatible output target. It would also be difficult to do one because WebAssembly currently doesn't have the necessary hooks to scan its stack for GC pointers. Maybe OCaml already maintains a manual stack or can be modified to do so, I don't know.

The interpreter is written in portable C and maintains its own stack so it makes this easy.

However, a big downside of WebAssembly code right now is that VMs implement it as an AOT compilation toolchain. That means that you spend a lot of time upfront compiling code.

If you have a lot of code paths that are not hot, you're wasting a lot more cycles compiling it than it would take to run it in the interpreter. When you run it in the interpreter you can start executing code instantly.

It might be the case that browsers change to an interpreter mode in the future which might change this equation.

### Why not compile OCaml code to JavaScript like js_of_ocaml or BuckleScript?

This is probably still the best technique if you want full GC interop and it gives you JIT capabilities for hot paths.

However, if you have a lot of code that means a lot of JavaScript to parse and compile on the client during start up. The benefit of running a bytecode is that it can immediately start executing.

Additionally, by using the GC built specifically for OCaml, you take advantage of more predictable and consistent GC behavior across browsers.

Multicore OCaml is coming and so is Shared Typed Array Buffers and Atomics for the web. By using a custom memory model we'll be able to take advantage of parallelism in the browser.

## Installation

I have only tried this on OS X so far and haven't polished any build scripts yet.

### 1. Browser

To test this you'll need a browser with WebAssembly enabled such as [Chrome Canary](https://www.google.com/chrome/browser/canary.html).

### 2. Emsdk

First you need to install the Emscripten SDK. According to the [WebAssembly Developer's Guide](http://webassembly.org/getting-started/developers-guide/) you need to currently build the toolchain from source. It says to include `binaryen-master-64bit` but that didn't work for me and currently I don't need it. `sdk-incoming-64bit` should be enough. (Note: This will need a lot of disk space to rebuild clang from source.)

```
git clone https://github.com/juj/emsdk.git
cd emsdk
./emsdk install sdk-incoming-64bit
./emsdk activate sdk-incoming-64bit
```

After these steps, the installation is complete. To enter an Emscripten compiler environment in the current command line prompt, type

```
source ./emsdk_env.sh
```

Return to the project folder.

### 3. Checkout the OCaml source code

The ocaml source is checked out as a Git submodule of this project.

```
git submodule update --init --recursive
```

### 4. Build

In the root of this repo run the build script.

```
./build.sh
```

It will build the example.ml file into OCaml bytecode. This will then be embedded into emscripten's virtual file system.

It will also build the OCaml bytecode interpreter and GC into a Web Assembly file.

`example.html` contains the bootstrapping script.

You can try it out in your browser using `emrun` (or just server it over HTTP yourself).

```
emrun --browser=chrome_canary example.html
```

It should print to the console with the default example.

### Next Steps

This is just the easiest set up to build to get started. However, emscripten and ocamlrun has a lot of features such a virtual file system and dynamic linking that is often not applicable to the web context. We'll want to strip that down into the smallest possible library that can fit neatly into an existing web toolchain.

This script also compiles with the `-O2` flag. We should see if we could cut down of file size with one of the other flags.
