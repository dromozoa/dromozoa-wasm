// [emscripten]
// . /opt/emsdk/emsdk_env.sh
// em++ -O3 -sPURE_WASI practice0001.cpp -o practice0001
//
// [wabt]
// wasm2wat practice0001.wasm
//
// [wasm-tools]
// wasm-tools print practice0001.wasm
//
// [wasmer]
// wasmer run practice0001.wasm
//
// [wasmtime]
// wasmtime run practice0001.wasm

#include <unistd.h>

int main() {
  write(1, "Hello World\n", 12);
  return 0;
}
