(module
  (import "wasi_unstable" "fd_write"
    (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_unstable" "args_sizes_get"
    (func $args_sizes_get (param i32 i32) (result i32)))
  (import "wasi_unstable" "args_get"
    (func $args_get (param i32 i32) (result i32)))

  ;; <  1KiB : 予約領域（0をnullptrとして扱いたい）
  ;; < 16KiB : データ領域   : 15KiB
  ;; < 32KiB : スタック領域 : 16KiB
  ;; < 64KiB : ヒープ領域   : 32KiB
  (memory $memory (export "memory") 1)

  (global $stack_ptr (mut i32) (i32.const 16384))
  (global $stack_end i32 (i32.const 32768))

  (func $roundup (param $v i32)(param $n i32)(result i32)
    (local $mask i32)

    (local.set $mask
      (i32.sub
        (i32.shl (i32.const 1) (local.get $n))
        (i32.const 1)))

    (i32.and
      (i32.add (local.get $v) (local.get $mask))
      (i32.xor (local.get $mask) (i32.const -1)))
  )

  (func $stack_allocate (param $size i32)(result i32)
    (local $sp_cur i32)
    (local $sp_new i32)

    ;; $sizeは8の倍数にする
    (local.set $size (call $roundup (local.get $size) (i32.const 3)))

    (i32.ge_u
      (local.tee $sp_new
        (i32.add
          (local.tee $sp_cur (global.get $stack_ptr))
          (local.get $size)))
      (global.get $stack_end))
    if
      unreachable
    end
    (global.set $stack_ptr (local.get $sp_new))

    local.get $sp_cur
  )

  (func $strlen (param $s i32)(result i32)
    (local $i i32)

    (local.set $i (i32.const 0))
    loop $loop
      (i32.eqz (i32.eqz (i32.load8_u (i32.add (local.get $s) (local.get $i)))))
      if
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        br $loop
      end

    end

    (local.get $i)
  )

  (func $write_string (param $fd i32)(param $data i32)(param $size i32)
    (local $sp i32)
    (local.set $sp (call $stack_allocate (i32.const 12)))

    (i32.store (local.get $sp) (local.get $data))
    (i32.store offset=4 (local.get $sp) (local.get $size))

    (call $fd_write
      (local.get $fd)
      (local.get $sp)
      (i32.const 1)
      (i32.add (local.get $sp) (i32.const 8)))
    (drop)

    (global.set $stack_ptr (local.get $sp))
  )

  (func $write_char (param $fd i32)(param $char i32)
    (local $sp i32)
    (local.set $sp (call $stack_allocate (i32.const 16)))

    (i32.store8 (local.get $sp) (local.get $char))
    (i32.store offset=4 (local.get $sp) (local.get $sp))
    (i32.store offset=8 (local.get $sp) (i32.const 1))

    (call $fd_write
      (local.get $fd)
      (i32.add (local.get $sp) (i32.const 4))
      (i32.const 1)
      (i32.add (local.get $sp) (i32.const 12)))
    (drop)

    (global.set $stack_ptr (local.get $sp))
  )

  (func $write_i32_dec (param $fd i32)(param $v i32)
    (local $sp i32)
    (local $p i32)
    (local $i i32)
    (local $r i32)

    (local.set $sp (call $stack_allocate (i32.const 12)))

    (local.set $p (i32.add (local.get $sp) (i32.const 11)))

    (local.set $i (i32.const 0))
    loop $loop
      (local.set $r (i32.rem_u (local.get $v) (i32.const 10)))
      (local.set $v (i32.div_u (local.get $v) (i32.const 10)))
      (i32.store8
        (i32.sub (local.get $p) (local.get $i))
        (i32.add (local.get $r) (i32.const 0x30)))

      (local.get $v)
      (i32.eqz)
      (i32.eqz)
      if ;; $vが0でなければ
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        br $loop
      end
    end

    (call $write_string
      (local.get $fd)
      (i32.sub (local.get $p) (local.get $i))
      (i32.add (local.get $i) (i32.const 1)))

    (global.set $stack_ptr (local.get $sp))
  )

  (func (export "_start")
    (local $sp i32)
    (local $result i32)
    (local $argc i32)
    (local $argv_buffer_size i32)
    (local $stack_size i32)
    (local $buffer i32)
    (local $i i32)
    (local $p i32)

    (local.set $sp (call $stack_allocate (i32.const 8)))

    (local.set $result
      (call $args_sizes_get
        (local.get $sp)
        (i32.add (local.get $sp) (i32.const 4))))

    (local.set $argc (i32.load (local.get $sp)))
    (local.set $argv_buffer_size (i32.load offset=4 (local.get $sp)))

    (call $write_i32_dec (i32.const 1) (local.get $argc))
    (call $write_char (i32.const 1) (i32.const 0x0A))

    (call $write_i32_dec (i32.const 1) (local.get $argv_buffer_size))
    (call $write_char (i32.const 1) (i32.const 0x0A))

    (call $write_i32_dec (i32.const 1) (local.get $result))
    (call $write_char (i32.const 1) (i32.const 0x0A))

    (global.set $stack_ptr (local.get $sp))

    (local.set $stack_size
      (i32.add
        (local.tee $buffer
          (i32.mul (local.get $argc) (i32.const 4)))
        (local.get $argv_buffer_size)))
    (call $write_i32_dec (i32.const 1) (local.get $stack_size))
    (call $write_char (i32.const 1) (i32.const 0x0A))

    (local.set $sp (call $stack_allocate (local.get $stack_size)))

    (local.set $result
      (call $args_get
        (local.get $sp)
        (i32.add (local.get $sp) (local.get $buffer))))

    (call $write_i32_dec (i32.const 1) (local.get $result))
    (call $write_char (i32.const 1) (i32.const 0x0A))

    (local.set $i (i32.const 0))
    loop $loop
      (local.set $p
        (i32.load
          (i32.add (local.get $sp) (i32.mul (local.get $i) (i32.const 4)))))
      (call $write_string
        (i32.const 1)
        (local.get $p)
        (call $strlen (local.get $p)))
      (call $write_char (i32.const 1) (i32.const 0x0A))

      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (i32.lt_u (local.get $i) (local.get $argc))
      if
        br $loop
      end
    end

    ;; (call $stack_allocate (i32.load offset=4 (local.get $sp)))
    ;; (drop)

    ;; (call $write_i32_dec (i32.const 1) (call $roundup (i32.const 1) (i32.const 3)))
    ;; (call $write_char (i32.const 1) (i32.const 0x0A))

    (global.set $stack_ptr (local.get $sp))
  )

  (data $memory (i32.const 1024) "test\n")
)
