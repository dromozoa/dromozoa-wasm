;; https://webassembly.github.io/spec/core/text/lexical.html#comments

;; 行コメント

(;
  ブロックコメント
;)

;; wasm2watで (;0;) のようにIDが出力される

;; https://webassembly.github.io/spec/core/text/modules.html#text-module
(module
  ;; https://webassembly.github.io/spec/core/text/modules.html#memories
  ;; (memory id? min max?)
  ;; ページサイズは65536 (64Ki)
  (memory $x 1)

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-export
  (export "memory" (memory $x))

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-func
  (func $main
    i32.const 0
    i32.const 42
    i32.store
  )

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-export
  (export "_start" (func $main))
)
