(module
  ;; <  1KiB : 予約領域（0をnullptrとして扱いたい）
  ;; < 16KiB : データ領域   : 15KiB
  ;; < 32KiB : スタック領域 : 16KiB
  ;; < 64KiB : ヒープ領域   : 32KiB
  (memory (export "memory") 1)

  (global $stack_ptr (mut i32) (i32.const 16384))
  (global $stack_end i32 (i32.const 32768))

  (func $stack_allocate (param $size i32)(result i32)
    (;
      int stack_allocate(int $size) {
        int $sp_cur = $stack_ptr;
        int $sp_new = $sp_cur + $size;
        if ($sp_new >= $stack_end) {
          unreachable;
        }
        $stack_ptr = $sp_cur;
        return $sp_cur;
      }
    ;)
    (local $sp_cur i32)
    (local $sp_new i32)
    global.get $stack_ptr
    local.tee $sp_cur
    local.get $size
    i32.add
    local.tee $sp_new
    global.get $stack_end
    i32.ge_u
    if
      unreachable
    end
    local.get $sp_new
    global.set $stack_ptr
    local.get $sp_cur
  )

  (func (export "_start")
    ;; i32.const 12
    (call $stack_allocate (i32.const 12))
    drop
  )
)
