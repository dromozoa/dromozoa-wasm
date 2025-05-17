(module
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_unstable" "clock_res_get" (func $clock_res_get (param i32 i32) (result i32)))
  (import "wasi_unstable" "clock_time_get" (func $clock_time_get (param i32 i64 i32) (result i32)))

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

  (func $print_i64 (param $v i64)
    (local $p i32)
    (local $n i32)
    (local $q i32)
    (local $u i64)

    ;; $p = new(32) + 32
    i32.const 32
    call $new
    i32.const 32
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

    loop $L
      ;; $u = $v % 10
      local.get $v
      i64.const 10
      i64.rem_u
      local.set $u

      ;; $v = $v / 10
      local.get $v
      i64.const 10
      i64.div_u
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
      i64.const 0x30
      i64.add
      i64.store8

      ;; $v != 0
      local.get $v
      i64.const 0
      i64.ne
      br_if $L
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


  (func $test1
    (local $p i32)
    (local $q i32)
    (local $t0 i64)
    (local $t1 i64)

    ;; clockid
    ;;   realtime
    ;;   monotonic
    ;;   process_cputime_id
    ;;   thread_cputime_id

    ;; clockid.realtime
    i32.const 0

    ;; new(sizeof(u64))
    i32.const 8
    call $new
    local.tee $p

    call $clock_res_get

    call $print_i32

    local.get $p
    i64.load
    call $print_i64

    ;; clockid.realtime
    i32.const 0

    ;; precision (unused?)
    i64.const 0

    ;; new(sizeof(u64))
    i32.const 8
    call $new
    local.tee $q

    call $clock_time_get

    call $print_i32

    local.get $q
    i64.load
    local.tee $t0
    call $print_i64

    i32.const 0
    i64.const 0
    local.get $q
    call $clock_time_get

    call $print_i32

    local.get $q
    i64.load
    local.tee $t1
    call $print_i64

    local.get $t1
    local.get $t0
    i64.sub
    call $print_i64
  )

  (func $main
    call $test1
  )
  (export "_start" (func $main))
)
