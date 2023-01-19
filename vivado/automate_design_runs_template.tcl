set PROJECT_NAME              bnn-accel_{registers}_{crossbars}_{xnor_gates}_{popcount_bits}
set PROJECT_CONSTRAINT_FILE ./vivado/clock.xdc
# set DIR_OUTPUT ./layout
set DIR_OUTPUT ./layout/bnn-accel_{registers}_{crossbars}_{xnor_gates}_{popcount_bits}
            
file mkdir ${{DIR_OUTPUT}}
# create project with part of Zynq UltraScale+ MPSoC ZCU104 Evaluation Kit
create_project -force ${{PROJECT_NAME}} ${{DIR_OUTPUT}}/${{PROJECT_NAME}} -part xczu7ev-ffvc1156-2-e
# add_files {{./build/computing_column.vhdl }}
# choose between accumulator and accumulator multiregs based on using vertical move / strided move
# add_files {{./build/accumulator.vhdl }}
add_files {{./build/controller_vm.vhdl }}
add_files {{./build/computing_column_vm.vhdl }}
add_files {{./build/accumulator_s.vhdl }}
add_files {{./build/adder.vhdl }}
add_files {{./build/popcount.vhdl }}
add_files {{./build/regfile.vhdl }}
add_files {{./build/register_dff.vhdl }}
add_files {{./build/xnor_gate.vhdl }}
add_files {{./build/xnor_gate_array.vhdl }}
import_files -force
import_files -fileset constrs_1 -force -norecurse ${{PROJECT_CONSTRAINT_FILE}}

# set top file 
set_property top controller_vm [current_fileset]

# Mimic GUI behavior of automatically setting top and file compile order
update_compile_order -fileset sources_1

# start synthesis with set generics:
synth_design -generic nr_xnor_gates={xnor_gates} -generic nr_computing_columns={crossbars} -generic acc_data_width=16
# -generic input_width={popcount_output_bits} -generic data_width=32 -generic addr_width={address_bits} -generic nr_regs={registers}

# Launch Synthesis and wait on completion
# launch_runs synth_1
# wait_on_run synth_1
# comment out the open_run for batch mode
# open_run synth_1 -name netlist_1

# report utilization after synthesis
report_utilization -file ${{DIR_OUTPUT}}/post_place_util.rpt

# Launch Implementation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1 


# Generate a timing and power reports and write to disk
# comment out the open_run for batch mode
# open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ${{DIR_OUTPUT}}/imp_timing.rpt
report_power -file ${{DIR_OUTPUT}}/imp_power.rpt


# comment out the for batch mode
# start_gui

exit