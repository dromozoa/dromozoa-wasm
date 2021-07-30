clean::
	rm -f *.wasm


%.wasm: %.wat
	wat2wasm --enable-bulk-memory $<
