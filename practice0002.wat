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

(module
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory 16)

  (func $main
    i32.const 42
    call $proc_exit
    unreachable
  )

  (export "memory" (memory 0))
  (export "_start" (func $main))
)
