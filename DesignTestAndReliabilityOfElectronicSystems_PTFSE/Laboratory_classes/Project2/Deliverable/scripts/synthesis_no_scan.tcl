# Cadence GENUS

# Paths
set LIB_DIR "/opt/ic_tools/pdk/ams_c35_410/liberty/c35_3.3V"
set_db init_lib_search_path $LIB_DIR
set_db init_hdl_search_path {.}

# Read the library
read_libs c35_CORELIB_TYP.lib

# Read the circuit
read_hdl sources/circuito06.v

# Elaboration (pre-synthesis)
elaborate circuito06

# Analyze the design
check_design

# Define the name of the clock signal and its period (ns)
create_clock -name clk -period 10000 [get_ports clock]

# Check for DFT violations
check_dft_rules > dft_rules_no_scan.report

# Synthesize
set_db syn_global_effort high
syn_generic
syn_map

# Generate report
report dft_registers

# Generate reports
report qor
write_hdl -mapped > circuito06_no_scan_syn.v 
write_sdc > circuito06_no_scan.sdc
write_atpg -stil > circuito06_no_scan.stil
report gates > circuito06_no_scan_gates.txt
report timing > circuito06_no_scan_timing.txt
report power > circuito06_no_scan_power.txt

exit