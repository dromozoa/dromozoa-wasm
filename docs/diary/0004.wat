(module
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory $memory 1)
  (export "memory" (memory $memory))

  (global $new_ptr (mut i32) (i32.const 0))

  ;; メモリは解放しない
  (func $new (param $size i32) (result i32)
    (local $ptr i32)

    global.get $new_ptr
    local.set $ptr

    local.get $ptr
    local.get $size
    i32.add

    global.set $new_ptr
    local.get $ptr
  )

  (func $write_i32 (param $v i32)
    (local $ptr i32)

    ;; $ptr = new(16)
    i32.const 16
    call $new
    local.set $ptr

    ;; *($ptr+8) = $v
    local.get $ptr
    i32.const 8
    i32.add
    local.get $v
    i32.store

    ;; *($ptr) = $ptr + 8
    local.get $ptr
    local.get $ptr
    i32.const 8
    i32.add
    i32.store

    ;; *($ptr+4) = 4
    local.get $ptr
    i32.const 4
    i32.add
    i32.const 4
    i32.store

    ;; $fd_write(1, $ptr, 1, ($ptr+12))
    i32.const 1
    local.get $ptr
    i32.const 1
    local.get $ptr
    i32.const 12
    i32.add
    call $fd_write

    drop
  )

  (func $test1
    i32.const 0x12345678
    call $write_i32
    i32.const 0xFEEDFACE
    call $write_i32
    i32.const -1
    call $write_i32
  )

  (func $test2
    i32.const 16
    call $new
    call $write_i32
  )

  (func $test3 (param $v i32)
    local.get $v
    i32.eqz
    ;; call $write_i32

    if
      i32.const 0x11111111
      call $write_i32
    else
      i32.const 0x22222222
      call $write_i32
    end
  )

  (func $test4 (param $v i32)
    block $L
      local.get $v
      i32.eqz

      br_if $L

      i32.const 0x11111111
      call $write_i32
    end
  )

  (func $test5 (param $v i32)
    (local $i i32)

    i32.const 0
    local.set $i

    (;
      do {
        // ...
        $i = $i + 1
      } while ($i != $v)
    ;)

    loop $L
      local.get $i
      call $write_i32

      local.get $i
      i32.const 1
      i32.add
      local.set $i

      local.get $i
      local.get $v
      i32.ne
      br_if $L
    end
  )

  (func $main
    ;; call $test1
    ;; call $test2
    i32.const 6
    call $test5
  )
  (export "_start" (func $main))
)
