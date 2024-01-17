# Remove the '#' to enable the graphical interface
#GUI = -gui -access +r

all:       SYN_dft_circuit SYN_final SIM_syn_top_level_normal SIM_syn_top_level_bist SIM_syn_top_level_controller FS_concurrent
top_level: all

############## Step 0: check for good Verilog coding style
HAL_circuit:
	hal -gui sources/circuito06.v

HAL_inputLFSR:
	hal -gui sources/inputLFSR.v

HAL_stateLFSR:
	hal -gui sources/stateLFSR.v

HAL_MISR:
	hal -gui sources/misr.v

HAL_controller:
	hal -gui sources/controller.v

# Must be done after synthesis of circuito06
HAL_circuit_syn:
	hal -gui sources/circuito06_scan_syn.v

# Must be done after synthesis of circuito06
HAL_all:
	hal -gui sources/circuito06_scan_syn.v sources/inputLFSR.v sources/stateLFSR.v sources/misr.v sources/controller.v sources/top_level.v

############## Step 1: behavioral simulation - testbenches not submitted for evaluation
SIM_rtl_circuit:
	xrun $(GUI) sources/circuito06.v testbenches/circuito06_tb.v

SIM_rtl_LFSR:
	xrun $(GUI) sources/inputLFSR.v sources/stateLFSR.v testbenches/lfsr_tb.v

SIM_rtl_MISR:
	xrun $(GUI) sources/misr.v testbenches/misr_tb.v

SIM_rtl_controller:
	xrun $(GUI) sources/controller.v testbenches/controller_tb.v

############## Step 1.5: synthesize the circuit without scan chain to check gate count and area
SYN_no_scan_circuit:
	genus -f scripts/synthesis_no_scan.tcl
	sed -i '1s/^/`timescale 1us\/1ps /' circuito06_no_scan_syn.v

############## Step 2: synthesize the circuit with scan chain
SYN_dft_circuit:
	genus -f scripts/synthesis_dft.tcl
	sed -i '1s/^/`timescale 1us\/1ps /' sources/circuito06_scan_syn.v

############## Step 3: gate-level simulation - testbench not submitted for evaluation
SIM_syn_scan_circuit:
	xrun $(GUI) -define SCAN -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		sources/circuito06_scan_syn.v\
		testbenches/circuito06_tb.v

############## Step 4a: simulate the whole design in "normal mode" - top Level (behavioral) + circuit with scan chain (gate-level)
SIM_rtl_top_level_normal:
	xrun $(GUI) -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		sources/circuito06_scan_syn.v\
		sources/controller.v\
		sources/inputLFSR.v\
		sources/misr.v\
		sources/stateLFSR.v\
		sources/top_level.v\
		testbenches/testbench_normal.v

############## Step 4b: simulate the whole design in "BIST mode" - top Level (behavioral) + circuit with scan chain (gate-level)
SIM_rtl_top_level_bist:
	xrun $(GUI) -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		sources/circuito06_scan_syn.v\
		sources/controller.v\
		sources/inputLFSR.v\
		sources/misr.v\
		sources/stateLFSR.v\
		sources/top_level.v\
		testbenches/testbench_bist.v

############## Step 4c: simulate the whole design in "controller mode" - top Level (behavioral) + circuit with scan chain (gate-level)
SIM_rtl_top_level_controller:
	xrun $(GUI) -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		sources/circuito06_scan_syn.v\
		sources/controller.v\
		sources/inputLFSR.v\
		sources/misr.v\
		sources/stateLFSR.v\
		sources/top_level.v\
		testbenches/testbench_controller.v

############## Step 5: synthesize the top level
SYN_final:
	genus -f scripts/synthesis.tcl
	sed -i '1s/^/`timescale 1us\/1ps /' top_level_syn.v

############## Step 7a: simulate the whole design in "normal mode" (gate-level simulation)
SIM_syn_top_level_normal:
	xrun $(GUI) -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_level_syn.v\
		testbenches/testbench_normal.v

############## Step 7b: simulate the whole design in "bist mode" (gate-level simulation)
SIM_syn_top_level_bist:	
	xrun $(GUI) -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_level_syn.v\
		testbenches/testbench_bist.v

############## Step 7c: simulate the whole design in "controller mode" (gate-level simulation)
SIM_syn_top_level_controller:
	xrun $(GUI) -l verilog.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_level_syn.v\
		testbenches/testbench_controller.v


############## Step 8: concurrent fault simulation
FS_concurrent:
	# Elaborate
	xrun -clean -elaborate\
 		-define functional\
		-fault_file scripts/fault.file\
		-fault_top top_level\
		-fault_logfile fault_xrun_elab.log\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/udp.v\
		-v /opt/ic_tools/pdk/ams_c35_410/verilog/c35b4/c35_CORELIB.v\
		top_level_syn.v\
		testbenches/testbench_bist.v
	# Generate the fault list
	xfsg -fault_type SA0+SA1\
		-fault_list fault_list\
		-fault_work fault_db
	# Remove UNCONNECTED signals (e.g. outputs of FFs)
	sed '/UNCONNECTED/d' -i fault_list.tcl
	# Perform fault simulation
	xrun -R -fault_concurrent\
		-nospecify -notimingchecks -delay_mode zero -run -exit\
		-define functional\
		-input scripts/strobes.tcl\
		-input fault_list.tcl\
		-fault_logfile fault_xrun_sim.log
	# Generate the report
	xfr -verbose\
		-fault_work fault_db\
		-fault_report fault_report.txt\
		-log xfr.log

clean:
	rm -rf fault_db waves.shm fv xcelium.d circuito06* genus.* *.report fault_* hal* .hal* .rs* verilog.* xf* xrun* top_level*