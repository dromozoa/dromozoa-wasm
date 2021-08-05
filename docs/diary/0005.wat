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

  (func $print_i32 (param $v i32)
    (local $p i32)
    (local $n i32)
    (local $q i32)
    (local $u i32)

    ;; $p = new(16) + 16
    i32.const 16
    call $new
    i32.const 16
    i32.add
    local.set $p

    ;; $n = 0
    i32.const 0
    local.set $n


    ;; $p = $p - 1
    local.get $p
    i32.const 1
    i32.sub
    local.set $p

    ;; $n = $n + 1
    local.get $n
    i32.const 1
    i32.add
    local.set $n

    ;; *$p = '\n'
    local.get $p
    i32.const 0x0A
    i32.store8

    ;; if $v == 0 then ... else ... end
    local.get $v
    i32.eqz
    if
      ;; $p = $p - 1
      local.get $p
      i32.const 1
      i32.sub
      local.set $p

      ;; $n = $n + 1
      local.get $n
      i32.const 1
      i32.add
      local.set $n

      ;; *$p = '0'
      local.get $p
      i32.const 0x30
      i32.store8
    else
      loop $L
        ;; $u = $v % 10
        local.get $v
        i32.const 10
        i32.rem_u
        local.set $u

        ;; $v = $v / 10
        local.get $v
        i32.const 10
        i32.div_u
        local.set $v


        ;; $p = $p - 1
        local.get $p
        i32.const 1
        i32.sub
        local.set $p

        ;; $n = $n + 1
        local.get $n
        i32.const 1
        i32.add
        local.set $n

        ;; *$p = $u + '0'
        local.get $p
        local.get $u
        i32.const 0x30
        i32.add
        i32.store8


        ;; $v != 0
        local.get $v
        i32.const 0
        i32.ne
        br_if $L
      end
    end

    ;; $q = new(16)
    i32.const 16
    call $new
    local.set $q

    ;; *($q) = $p
    local.get $q
    local.get $p
    i32.store

    ;; *($q+4) = $n
    local.get $q
    i32.const 4
    i32.add
    local.get $n
    i32.store

    ;; $fd_write(1, $q, 1, ($q+8))
    i32.const 1
    local.get $q
    i32.const 1
    local.get $q
    i32.const 8
    i32.add
    call $fd_write

    drop
  )

  (func $main
    ;; call $test1
    ;; call $test2
    i32.const 0xFFFFFFFF
    call $print_i32
  )
  (export "_start" (func $main))
)
