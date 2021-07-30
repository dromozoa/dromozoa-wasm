(module
  ;; https://github.com/WebAssembly/WASI/blob/main/phases/snapshot/docs.md#-fd_writefd-fd-iovs-ciovec_array---resultsize-errno
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  ;; https://webassembly.github.io/spec/core/text/modules.html#memories
  ;; (memory id? min max?)
  ;; ページサイズは65536 (64Ki)
  (memory $x 1)

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-export
  (export "memory" (memory $x))

  (func $write_i32 (param $v i32)
    i32.const 0
    i32.const 8
    i32.store

    i32.const 4
    i32.const 4
    i32.store

    i32.const 8
    local.get $v
    i32.store

    i32.const 1
    i32.const 0
    i32.const 1
    i32.const 12
    call $fd_write

    drop
  )

  (func $write_memory (param $p i32)(param $n i32)(param $o i32)(param $fd i32)
    i32.const 0
    local.get $p
    i32.store

    i32.const 4
    local.get $n
    i32.store

    local.get $fd
    i32.const 0
    i32.const 1
    local.get $o
    call $fd_write

    ;; drop
    call $write_i32
  )

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-func
  (func $main
    i32.const 1024
    i32.const 0x12345678
    i32.store

    i32.const 2048 ;; d
    i32.const 0xCC ;; v
    i32.const 1024 ;; n
    memory.fill

    i32.const 1024
    i32.const 4
    i32.const 2048
    i32.const 1
    call $write_memory

    i32.const 2048
    i32.const 16
    i32.const 3072
    i32.const 1
    call $write_memory

    (;
    i32.const 4096 ;; d
    i32.const 0xFE ;; v
    i32.const 256  ;; n
    memory.fill

    i32.const 4096
    i32.const 16
    i32.const 5120
    i32.const 1
    call $write_memory

    i32.const 4096
    i32.const 16
    i32.const 5120
    i32.const 1
    call $write_memory
    ;)




  )

  ;; https://webassembly.github.io/spec/core/text/modules.html#start-function
  ;; (start $main)

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-export
  (export "_start" (func $main))
)
