all:
	arm-linux-gnueabihf-gcc -Dsoc_cv_av -O2 -o sprites_ctrl sprites_ctrl.c
	arm-linux-gnueabihf-strip -s sprites_ctrl
	
clean:
	rm -rf sprites_ctrl