(module
  ;; <  1KiB : 予約領域（0をnullptrとして扱いたい）
  ;; < 16KiB : データ領域   : 15KiB
  ;; < 32KiB : スタック領域 : 16KiB
  ;; < 64KiB : ヒープ領域   : 32KiB
  (memory (export "memory") 1)

  (global $stack_ptr (mut i32) (i32.const 16384))
  (global $stack_end i32 (i32.const 32768))

  (func (export "_start")
  )
)
