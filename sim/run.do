vlib work
vlog -f src_files.list  +cover -covercells
vsim -voptargs=+acc work.ALSU_top -classdebug -uvmcontrol=all -cover
add wave /ALSU_top/alsu_if/*
add wave /ALSU_top/sr_if/*
run 0
add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/alsu_env/alsu_sb/out_ref \
sim:/uvm_root/uvm_test_top/alsu_env/alsu_sb/leds_ref
add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/alsu_env/alsu_sb/correct_cnt \
sim:/uvm_root/uvm_test_top/alsu_env/alsu_sb/error_cnt
add wave -position insertpoint  \
sim:/uvm_root/uvm_test_top/alsu_env/alsu_sb/t

coverage exclude -src ALSU.v -line 107 -code s
coverage exclude -src ALSU.v -line 107 -code b

coverage exclude -cvgpath {/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/dataout/auto[44]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[21]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[22]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[23]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[27]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[28]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[38]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[39]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[42]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[44]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[45]} \
{/shift_reg_coverage_pkg/shift_reg_coverage/shift_reg_cvg/datain/auto[54]}

coverage save ALSU.ucdb -onexit

run -all

