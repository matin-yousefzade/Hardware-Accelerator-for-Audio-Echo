#include "amplitude_calculation.h"

void amplitude_circute_set_size(int size) {
	int slv_reg0 = IORD_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0);
	slv_reg0 = slv_reg0 & 0x80000FFF;
	slv_reg0 = slv_reg0 + size * 4096;
	IOWR_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0, slv_reg0);
}

void amplitude_circute_set_num(int num) {
	int slv_reg0 = IORD_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0);
	slv_reg0 = slv_reg0 & 0xFFFFF001;
	slv_reg0 = slv_reg0 + num * 2;
	IOWR_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0, slv_reg0);
}

void amplitude_circute_start(void) {
	int slv_reg0 = IORD_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0);
	slv_reg0 = slv_reg0 | 0x00000001;
	IOWR_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0, slv_reg0);
}

int amplitude_circute_get_status(void) {
	int slv_reg0 = IORD_32DIRECT(MAGNITUDE_CIRCUIT_0_BASE, 0);
	if(slv_reg0 > 0x80000000)
		return 1;
	else
		return 0;
}
