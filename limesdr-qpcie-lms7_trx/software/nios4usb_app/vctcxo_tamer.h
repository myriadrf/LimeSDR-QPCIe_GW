/*
 * vctcxo_tamer.h
 *
 *  Created on: Feb 19, 2018
 *      Author: Vytautas
 */

#ifndef VCTCXO_TAMER_H_
#define VCTCXO_TAMER_H_

/* VCTCXO tamer register offsets */
#   define VT_CTRL_ADDR      		(0x00)
#   define VT_STAT_ADDR      		(0x01)
#   define VT_ERR_1S_ADDR    		(0x04)
#   define VT_ERR_10S_ADDR   		(0x0C)
#   define VT_ERR_100S_ADDR  		(0x14)
# 	define VT_STATE_ADDR     		(0x1C)
# 	define VT_DAC_TUNNED_VAL_ADDR0 	(0x20)
# 	define VT_DAC_TUNNED_VAL_ADDR1 	(0x21)

/* VCTCXO tamer control/status bits */
#   define VT_CTRL_RESET     		(0x01)
#   define VT_CTRL_IRQ_EN    		(1<<4)
#   define VT_CTRL_IRQ_CLR   		(1<<5)
#   define VT_CTRL_TUNE_MODE 		(0xC0)

#   define VT_STAT_ERR_1S    		(0x01)
#   define VT_STAT_ERR_10S   		(1<<1)
#   define VT_STAT_ERR_100S  		(1<<2)

#endif /* VCTCXO_TAMER_H_ */
