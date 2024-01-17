# Cadence GENUS

# Paths
set LIB_DIR "/opt/ic_tools/pdk/ams_c35_410/liberty/c35_3.3V"
set_db init_lib_search_path $LIB_DIR
set_db init_hdl_search_path {.}

# Read the library
read_libs c35_CORELIB_TYP.lib

# Read the circuit
read_hdl sources/top_level.v sources/controller.v sources/inputLFSR.v sources/stateLFSR.v sources/misr.v sources/circuito06_scan_syn.v

# Elaboration (pre-synthesis)
elaborate top_level

# Analyze the design
check_design

# Define the name of the clock signal and its period (ns)
create_clock -name clock -period 10000 [get_ports clock]

# Read the constraints from an SDC file
#read_sdc <SDC file>

# Synthesize
set_db syn_global_effort high
syn_generic
syn_map

# Create a flatten circuit (circuit with only one module) 
ungroup -all

# Generate reports
report qor
write_hdl -mapped > top_level_syn.v
write_sdc > top_level.sdc
report gates > top_level_gates.txt
report timing > top_level_timing.txt
report power > top_level_power.txt

exit