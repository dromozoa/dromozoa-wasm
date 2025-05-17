;; componentの練習
(component
  (core module $module

    (memory (export "memory") 1)

    (func $main
    )

    (export "_start" (func $main))

  )

  (core instance $instance (instantiate $module))
  ;; (export "_start" (func $instance "_start"))

(;
  (type $wasi_fd_write (func (param i32 i32 i32 i32) (result i32)))

  (import "wasi:cli/snapshot-preview1" (instance $wasi
    (export "fd_write" (func (type $wasi_fd_write)))
  ))

  (core module $module
    (import "wasi_snapshot_preview1" "fd_write"
      (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory (export "memory") 1)
    (data (i32.const 8) "Hello, World!\n")

    (func $main
      i32.const 1
      i32.const 8
      i32.const 14
      i32.const 0
      call $fd_write
      drop
    )

    (export "_start" (func $main))
  )

  (instance $instance (instantiate $module (with $wasi)))
  (export "_start" (func core $instance "_start"))
;)

  ;; https://github.com/WebAssembly/WASI/blob/main/phases/snapshot/docs.md
  ;; https://github.com/WebAssembly/component-model/tree/main/design/mvp
  ;;
  ;; fd_write(fd:fd, iovs:ciovec_array)->Result<size, errno>
  ;; fd: Handle
  ;;   Handleはi32と考えてよいらしい
  ;; ciovec_array: List<ciovec>
  ;;   Listはポインタとサイズを持つ
  ;; ciovecは構造体
  ;;
  ;; wasmerの実装も参照する
  ;;
  ;; (fd, iovs.ptr, iovs.len, size.ptr) -> (errno)
  ;; (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
)
