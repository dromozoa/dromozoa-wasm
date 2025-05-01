(module
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
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
)
