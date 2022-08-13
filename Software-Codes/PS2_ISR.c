#include "globals.h"

extern volatile unsigned char byte1, byte2, byte3;
extern volatile int n, f;

/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine checks which KEY has been pressed. If it is KEY1 or KEY2, it writes this 
 * value to the global variable key_pressed. If it is KEY3 then it loads the SW switch 
 * values and stores in the variable pattern
****************************************************************************************/
void PS2_ISR(struct alt_up_dev *up_dev, unsigned int id)
{
	unsigned char PS2_data;

	if (alt_up_ps2_read_data_byte (up_dev->PS2_dev, &PS2_data) == 0)
	{
		if(n == 0) byte1 = PS2_data;
		else if(n == 1) byte2 = PS2_data;
		else if(n == 2) byte3 = PS2_data;

		if(n == 2) {
			n = 0;
			f = 1;
		}
		else {
			n++;
			f = 0;
		}
	}
	return;
}
