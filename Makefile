module=fetch_i
start=0
stop=20000

build_defines=  +define+ADDR_LEN=11 \
		+define+ADDRS=2048 \
		+define+DATA_LEN=40 \
		+define+OP_SIZE=32 \

all:
	python3 generate_testbench.py ${module} ${start} ${stop}
	rm -rf obj_dir
	rm -f packed.vcd
	verilator ${build_defines} --cc --main --build --exe --timing --trace -CFLAGS "-std=c++20" testbench.sv
	./obj_dir/Vtestbench
