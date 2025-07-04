;; https://webassembly.github.io/spec/core/text/modules.html#modules
(module
  ;; funcのabbrでimportを書けるけど、順序問題があるからimportメインのほうがよいかも。
  (func $proc_exit (import "wasi_snapshot_preview1" "proc_exit") (param i32))

  ;; https://wasix.org/docs/api-reference/wasi/fd_write
  ;; 結果の定義は下記のようになっている:
  ;; (result $error (expected $size (error $errno)))
  ;; https://github.com/WebAssembly/WASI/blob/main/legacy/tools/witx-docs.md
  ;; 成功の場合は0が返り、失敗の場合は$errnoが返る。
  ;; 成功の場合は第4引数のポインタ先に$sizeが格納される。
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  ;; https://webassembly.github.io/spec/core/text/modules.html#memories
  ;; ページサイズは64KiB
  (memory $memory (export "memory") 1)

  ;; https://webassembly.github.io/spec/core/text/modules.html#globals
  (global $SP (mut i32) (i32.const 8192))

  (func $write (param $fd i32)(param $data i32)(param $size i32)(result i32)
    ;; struct iovs {
    ;;   const void* data;
    ;;   size_t size;
    ;; }
    (local $sp i32)
    global.get $SP
    local.tee $sp
    i32.const 12
    i32.add
    global.set $SP

    local.get $sp
    local.get $data
    i32.store

    local.get $sp
    local.get $size
    i32.store offset=4

    local.get $fd
    local.get $sp
    i32.const 1
    local.get $sp
    i32.const 8
    i32.add

    call $fd_write

    local.get $sp
    global.set $SP
  )

  ;; https://webassembly.github.io/spec/core/text/modules.html#functions
  (func $main (export "_start")
    i32.const 1
    i32.const 1024
    i32.const 12
    call $write
    call $proc_exit
    ;; unreachable
  )

  (data $memory (i32.const 1024) "Hello World\n")
)
