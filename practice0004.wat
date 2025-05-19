(module
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  ;; <  1KiB : 予約領域（0をnullptrとして扱いたい）
  ;; < 16KiB : データ領域   : 15KiB
  ;; < 32KiB : スタック領域 : 16KiB
  ;; < 64KiB : ヒープ領域   : 32KiB
  (memory $memory (export "memory") 1)

  (global $stack_ptr (mut i32) (i32.const 16384))
  (global $stack_end i32 (i32.const 32768))

  (func $stack_allocate (param $size i32)(result i32)
    (;
      function stack_allocate(size <i32>) <i32>
        local sp_cur <i32> = stack_ptr
        local sp_new <i32> = sp_cur + size
        if sp_new >= stack_end then
          unreachable
        end
        stack_ptr = sp_new
        return sp_cur
      end
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

  (func $write_string (param $fd i32)(param $data i32)(param $size i32)
    (;
      local sp <i32> = stack_allocate(12)
      memory[sp] = data
      memory[sp + 4] = size
      fd_write(fd, sp, 1, sp + 8)
      stack_ptr = sp
    ;)

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
    (;
      local sp <i32> = stack_allocate(16)
      memory[sp] = char <i8>
      memory[sp + 4] = sp
      memory[sp + 8] = 1
      fd_write(fd, sp + 4, 1, sp + 12)
      stack_ptr = sp
    ;)

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
    (;
      local sp <i32> = stack_allocate(12)
      local p <i32> = $sp + 11
      local i <i32> = 0
      loop
        local r <i32> = v % 10
        v <i32> = v // 10
        memory[p - i] = (r + 0x30) <i32>
        if v != 0 then
          i = i + 1
          continue
        end
      end
      write_string(fd, p - i, i + 1)
      stack_ptr = sp
    ;)

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
    ;; i32.const 12
    ;; (call $stack_allocate (i32.const 12))
    (call $write_i32_dec (i32.const 1) (i32.const 10000))
    (call $write_char (i32.const 1) (i32.const 0x0A))
  )

  (data $memory (i32.const 1024) "test\n")
)
