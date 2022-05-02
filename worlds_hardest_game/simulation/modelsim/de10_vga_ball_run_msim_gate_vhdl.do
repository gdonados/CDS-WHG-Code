transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work {de10_vga_ball.vho}

vcom -93 -work work {C:/AdvDig/de10_vga_ball_sprites - Copy/de10_vga_raster_sprites_tb.vhd}

vsim -t 1ps +transport_int_delays +transport_path_delays -sdftyp /NA=de10_vga_ball_vhd.sdo -L altera -L altera_lnsim -L cyclonev -L gate_work -L work -voptargs="+acc"  de10_vga_raster_sprites_tb

add wave *
view structure
view signals
run 1 sec
