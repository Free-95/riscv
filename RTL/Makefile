# Define project-specific variables
TOP=soc
PCF_FILE=VSDSquadronFM
BOARD_FREQ=10
CPU_FREQ=12
FPGA_VARIANT=up5k
FPGA_PACKAGE=sg48
VERILOG_FILE_LIST=alu.v apb_master.v Clockworks.v control_unit.v data_mem.v Decode.v Execute.v extend.v Fetch.v instr_mem.v mux2.v mux4.v pc.v reg_file.v RiscV.v soc.v system_timer.v

#Uart Var	
PICO_DEVICE=/dev/ttyUSB0   # replace by the terminal used by your device
BAUDS=9600

build:
	yosys  -q -p "read_verilog $(VERILOG_FILE_LIST); synth_ice40 -top $(TOP) -json $(TOP).json" 
	nextpnr-ice40 --force --json $(TOP).json --pcf $(PCF_FILE).pcf --asc $(TOP).asc --freq $(BOARD_FREQ) --$(FPGA_VARIANT) --package $(FPGA_PACKAGE) --opt-timing
	icetime -p $(PCF_FILE).pcf -P $(FPGA_PACKAGE) -r $(TOP).timings -d $(FPGA_VARIANT) -t $(TOP).asc
	icepack -s $(TOP).asc $(TOP).bin

flash:
	iceprog $(TOP).bin

clean:
	rm -rf $(TOP).blif $(TOP).asc $(TOP).bin $(TOP).json $(TOP).timings

terminal:
	sudo picocom -b $(BAUDS) $(PICO_DEVICE) --imap lfcrlf,crcrlf --omap delbs,crlf --send-cmd "ascii-xfr -s -l 30 -n"
