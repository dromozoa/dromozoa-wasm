;; https://webassembly.github.io/spec/core/text/lexical.html#comments

;; 行コメント

(;
  ブロックコメント
;)

;; (module

  ;; https://webassembly.github.io/spec/core/text/modules.html#memories
  ;; (memory id? min max?)
  ;; ページサイズは65536 (64Ki)
  (memory $x 1 1)

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-func
  (func $main)

  ;; https://webassembly.github.io/spec/core/text/modules.html#start-function
  ;; (start $main)

  ;; https://webassembly.github.io/spec/core/text/modules.html#text-export
  (export "_start" (func $main))
;; )
