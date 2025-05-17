;; [wabt]
;; wat2wasm practice0002.wat
;;
;; [wasm-tools]
;; wasm-tools validate practice0002.wat
;; wasm-tools parse practice0002.wat -o practice0002.wasm
;;
;; [wasmer]
;; wasmer run practice0002.wasm
;;
;; [wasmtime]
;; wasmtime run practice0002.wasm

;; https://webassembly.github.io/spec/core/text/modules.html#modules
(module
  ;; https://webassembly.github.io/spec/core/text/modules.html#imports
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  ;; https://webassembly.github.io/spec/core/text/modules.html#memories
  ;; ページサイズは64KiB
  (memory $memory (export "memory") 1)

  ;; https://webassembly.github.io/spec/core/text/modules.html#functions
  (func $main (export "_start")
    i32.const 42
    call $proc_exit
    ;; unreachable
  )
)
