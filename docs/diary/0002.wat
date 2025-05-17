;; https://webassembly.github.io/spec/core/text/lexical.html#comments

;; 行コメント

(;
  ブロックコメント
;)

;; wasm2watで (;0;) のようにIDが出力される場合があるみたい

;; https://webassembly.github.io/spec/core/text/modules.html#text-module
(module
  ;; https://webassembly.github.io/spec/core/text/modules.html#text-import
  ;; fd, buf addren, buf length, result?
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  ;; https://webassembly.github.io/spec/core/text/modules.html#memories
  ;; (memory id? min max?)
  ;; ページサイズは65536 (64Ki)
  (memory $x 1)

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-export
  (export "memory" (memory $x))

  ;; record iovs
  ;;   buf: ConstPointer<u8>
  ;;   buf_len: size (u32)

  (func $write_byte (param $v i32)
    i32.const 0
    i32.const 8
    i32.store

    i32.const 4
    i32.const 1
    i32.store

    i32.const 8
    local.get $v
    i32.store8

    i32.const 1
    i32.const 0
    i32.const 1
    i32.const 12
    call $fd_write

    drop
  )

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

  (func $write_i32_2 (param $v i32)
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

    call $write_i32
  )

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-func
  (func $main
    (;
    i32.const 65
    call $write_byte

    i32.const 0x0a
    call $write_byte
    ;)

    i32.const 0x12345678
    call $write_i32_2
  )

  ;; https://webassembly.github.io/spec/core/text/modules.html#start-function
  ;; (start $main)

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-export
  (export "_start" (func $main))
)
