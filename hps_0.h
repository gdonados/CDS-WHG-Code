#ifndef _ALTERA_HPS_0_H_
#define _ALTERA_HPS_0_H_

/*
 * This file was automatically generated by the swinfo2header utility.
 * 
 * Created from SOPC Builder system 'hps' in
 * file 'hps.sopcinfo'.
 */

/*
 * This file contains macros for module 'hps_0' and devices
 * connected to the following master:
 *   h2f_lw_axi_master
 * 
 * Do not include this header file and another header file created for a
 * different module or master group at the same time.
 * Doing so may result in duplicate macro names.
 * Instead, use the system header file which has macros with unique names.
 */

/*
 * Macros for device 'de10_vga_raster_sprites_0', class 'de10_vga_raster_sprites'
 * The macros are prefixed with 'DE10_VGA_RASTER_SPRITES_0_'.
 * The prefix is the slave descriptor.
 */
#define DE10_VGA_RASTER_SPRITES_0_COMPONENT_TYPE de10_vga_raster_sprites
#define DE10_VGA_RASTER_SPRITES_0_COMPONENT_NAME de10_vga_raster_sprites_0
#define DE10_VGA_RASTER_SPRITES_0_BASE 0x0
#define DE10_VGA_RASTER_SPRITES_0_SPAN 131072
#define DE10_VGA_RASTER_SPRITES_0_END 0x1ffff

/*
 * Macros for device 'reset_switch', class 'altera_avalon_pio'
 * The macros are prefixed with 'RESET_SWITCH_'.
 * The prefix is the slave descriptor.
 */
#define RESET_SWITCH_COMPONENT_TYPE altera_avalon_pio
#define RESET_SWITCH_COMPONENT_NAME reset_switch
#define RESET_SWITCH_BASE 0x20000
#define RESET_SWITCH_SPAN 16
#define RESET_SWITCH_END 0x2000f
#define RESET_SWITCH_BIT_CLEARING_EDGE_REGISTER 0
#define RESET_SWITCH_BIT_MODIFYING_OUTPUT_REGISTER 0
#define RESET_SWITCH_CAPTURE 0
#define RESET_SWITCH_DATA_WIDTH 1
#define RESET_SWITCH_DO_TEST_BENCH_WIRING 0
#define RESET_SWITCH_DRIVEN_SIM_VALUE 0
#define RESET_SWITCH_EDGE_TYPE NONE
#define RESET_SWITCH_FREQ 50000000
#define RESET_SWITCH_HAS_IN 1
#define RESET_SWITCH_HAS_OUT 0
#define RESET_SWITCH_HAS_TRI 0
#define RESET_SWITCH_IRQ_TYPE NONE
#define RESET_SWITCH_RESET_VALUE 0

/*
 * Macros for device 'button_right', class 'altera_avalon_pio'
 * The macros are prefixed with 'BUTTON_RIGHT_'.
 * The prefix is the slave descriptor.
 */
#define BUTTON_RIGHT_COMPONENT_TYPE altera_avalon_pio
#define BUTTON_RIGHT_COMPONENT_NAME button_right
#define BUTTON_RIGHT_BASE 0x20010
#define BUTTON_RIGHT_SPAN 16
#define BUTTON_RIGHT_END 0x2001f
#define BUTTON_RIGHT_BIT_CLEARING_EDGE_REGISTER 0
#define BUTTON_RIGHT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUTTON_RIGHT_CAPTURE 0
#define BUTTON_RIGHT_DATA_WIDTH 1
#define BUTTON_RIGHT_DO_TEST_BENCH_WIRING 0
#define BUTTON_RIGHT_DRIVEN_SIM_VALUE 0
#define BUTTON_RIGHT_EDGE_TYPE NONE
#define BUTTON_RIGHT_FREQ 50000000
#define BUTTON_RIGHT_HAS_IN 1
#define BUTTON_RIGHT_HAS_OUT 0
#define BUTTON_RIGHT_HAS_TRI 0
#define BUTTON_RIGHT_IRQ_TYPE NONE
#define BUTTON_RIGHT_RESET_VALUE 0

/*
 * Macros for device 'button_left', class 'altera_avalon_pio'
 * The macros are prefixed with 'BUTTON_LEFT_'.
 * The prefix is the slave descriptor.
 */
#define BUTTON_LEFT_COMPONENT_TYPE altera_avalon_pio
#define BUTTON_LEFT_COMPONENT_NAME button_left
#define BUTTON_LEFT_BASE 0x20020
#define BUTTON_LEFT_SPAN 16
#define BUTTON_LEFT_END 0x2002f
#define BUTTON_LEFT_BIT_CLEARING_EDGE_REGISTER 0
#define BUTTON_LEFT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUTTON_LEFT_CAPTURE 0
#define BUTTON_LEFT_DATA_WIDTH 1
#define BUTTON_LEFT_DO_TEST_BENCH_WIRING 0
#define BUTTON_LEFT_DRIVEN_SIM_VALUE 0
#define BUTTON_LEFT_EDGE_TYPE NONE
#define BUTTON_LEFT_FREQ 50000000
#define BUTTON_LEFT_HAS_IN 1
#define BUTTON_LEFT_HAS_OUT 0
#define BUTTON_LEFT_HAS_TRI 0
#define BUTTON_LEFT_IRQ_TYPE NONE
#define BUTTON_LEFT_RESET_VALUE 0

/*
 * Macros for device 'button_down', class 'altera_avalon_pio'
 * The macros are prefixed with 'BUTTON_DOWN_'.
 * The prefix is the slave descriptor.
 */
#define BUTTON_DOWN_COMPONENT_TYPE altera_avalon_pio
#define BUTTON_DOWN_COMPONENT_NAME button_down
#define BUTTON_DOWN_BASE 0x20030
#define BUTTON_DOWN_SPAN 16
#define BUTTON_DOWN_END 0x2003f
#define BUTTON_DOWN_BIT_CLEARING_EDGE_REGISTER 0
#define BUTTON_DOWN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUTTON_DOWN_CAPTURE 0
#define BUTTON_DOWN_DATA_WIDTH 1
#define BUTTON_DOWN_DO_TEST_BENCH_WIRING 0
#define BUTTON_DOWN_DRIVEN_SIM_VALUE 0
#define BUTTON_DOWN_EDGE_TYPE NONE
#define BUTTON_DOWN_FREQ 50000000
#define BUTTON_DOWN_HAS_IN 1
#define BUTTON_DOWN_HAS_OUT 0
#define BUTTON_DOWN_HAS_TRI 0
#define BUTTON_DOWN_IRQ_TYPE NONE
#define BUTTON_DOWN_RESET_VALUE 0

/*
 * Macros for device 'button_up', class 'altera_avalon_pio'
 * The macros are prefixed with 'BUTTON_UP_'.
 * The prefix is the slave descriptor.
 */
#define BUTTON_UP_COMPONENT_TYPE altera_avalon_pio
#define BUTTON_UP_COMPONENT_NAME button_up
#define BUTTON_UP_BASE 0x20040
#define BUTTON_UP_SPAN 16
#define BUTTON_UP_END 0x2004f
#define BUTTON_UP_BIT_CLEARING_EDGE_REGISTER 0
#define BUTTON_UP_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUTTON_UP_CAPTURE 0
#define BUTTON_UP_DATA_WIDTH 1
#define BUTTON_UP_DO_TEST_BENCH_WIRING 0
#define BUTTON_UP_DRIVEN_SIM_VALUE 0
#define BUTTON_UP_EDGE_TYPE NONE
#define BUTTON_UP_FREQ 50000000
#define BUTTON_UP_HAS_IN 1
#define BUTTON_UP_HAS_OUT 0
#define BUTTON_UP_HAS_TRI 0
#define BUTTON_UP_IRQ_TYPE NONE
#define BUTTON_UP_RESET_VALUE 0

/*
 * Macros for device 'hex2', class 'altera_avalon_pio'
 * The macros are prefixed with 'HEX2_'.
 * The prefix is the slave descriptor.
 */
#define HEX2_COMPONENT_TYPE altera_avalon_pio
#define HEX2_COMPONENT_NAME hex2
#define HEX2_BASE 0x20050
#define HEX2_SPAN 16
#define HEX2_END 0x2005f
#define HEX2_BIT_CLEARING_EDGE_REGISTER 0
#define HEX2_BIT_MODIFYING_OUTPUT_REGISTER 0
#define HEX2_CAPTURE 0
#define HEX2_DATA_WIDTH 4
#define HEX2_DO_TEST_BENCH_WIRING 0
#define HEX2_DRIVEN_SIM_VALUE 0
#define HEX2_EDGE_TYPE NONE
#define HEX2_FREQ 50000000
#define HEX2_HAS_IN 0
#define HEX2_HAS_OUT 1
#define HEX2_HAS_TRI 0
#define HEX2_IRQ_TYPE NONE
#define HEX2_RESET_VALUE 0

/*
 * Macros for device 'hex1', class 'altera_avalon_pio'
 * The macros are prefixed with 'HEX1_'.
 * The prefix is the slave descriptor.
 */
#define HEX1_COMPONENT_TYPE altera_avalon_pio
#define HEX1_COMPONENT_NAME hex1
#define HEX1_BASE 0x20060
#define HEX1_SPAN 16
#define HEX1_END 0x2006f
#define HEX1_BIT_CLEARING_EDGE_REGISTER 0
#define HEX1_BIT_MODIFYING_OUTPUT_REGISTER 0
#define HEX1_CAPTURE 0
#define HEX1_DATA_WIDTH 4
#define HEX1_DO_TEST_BENCH_WIRING 0
#define HEX1_DRIVEN_SIM_VALUE 0
#define HEX1_EDGE_TYPE NONE
#define HEX1_FREQ 50000000
#define HEX1_HAS_IN 0
#define HEX1_HAS_OUT 1
#define HEX1_HAS_TRI 0
#define HEX1_IRQ_TYPE NONE
#define HEX1_RESET_VALUE 0

/*
 * Macros for device 'hex0', class 'altera_avalon_pio'
 * The macros are prefixed with 'HEX0_'.
 * The prefix is the slave descriptor.
 */
#define HEX0_COMPONENT_TYPE altera_avalon_pio
#define HEX0_COMPONENT_NAME hex0
#define HEX0_BASE 0x20070
#define HEX0_SPAN 16
#define HEX0_END 0x2007f
#define HEX0_BIT_CLEARING_EDGE_REGISTER 0
#define HEX0_BIT_MODIFYING_OUTPUT_REGISTER 0
#define HEX0_CAPTURE 0
#define HEX0_DATA_WIDTH 4
#define HEX0_DO_TEST_BENCH_WIRING 0
#define HEX0_DRIVEN_SIM_VALUE 0
#define HEX0_EDGE_TYPE NONE
#define HEX0_FREQ 50000000
#define HEX0_HAS_IN 0
#define HEX0_HAS_OUT 1
#define HEX0_HAS_TRI 0
#define HEX0_IRQ_TYPE NONE
#define HEX0_RESET_VALUE 0


#endif /* _ALTERA_HPS_0_H_ */
