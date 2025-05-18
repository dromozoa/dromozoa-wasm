# . /opt/emsdk/emsdk_env.sh

vpath %.cpp ..
vpath %.wat ..

TARGET = \
	practice0001.wasm \
	practice0002.wasm \
	practice0003.wasm

all:: $(TARGET)

clean::
	$(RM) $(TARGET) *.out *.wat

%.wasm: %.cpp
	em++ -O3 -sPURE_WASI $< -o $(basename $@).out
	wasm2wat $@ >$(basename $@).wat

%.wasm: %.wat
	wat2wasm $<
