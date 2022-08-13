#ifndef __AMPLITUDE_CALCULATION_H__
#define __AMPLITUDE_CALCULATION_H__

#include "system.h"
#include "io.h"

#ifdef __cplusplus
extern "C"
{
#endif

#define amplitude_circute_stop() IOWR_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0, 0)

#define amplitude_circute_set_rbuff_addr(RBUFF_ADDR) IOWR_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 4, RBUFF_ADDR)

#define amplitude_circute_set_lbuff_addr(LBUFF_ADDR) IOWR_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 8, LBUFF_ADDR)

#define amplitude_circute_set_dest_addr(DEST_ADDR) IOWR_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 12, DEST_ADDR)

extern void amplitude_circute_set_size(int size);

extern void amplitude_circute_set_num(int num);

extern void amplitude_circute_start(void);

extern int amplitude_circute_get_status(void);

#ifdef __cplusplus
}
#endif

#endif
