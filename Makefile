all 	:
	make -C src/

test 	: all
	./compil.sh tst/test.myc

clean	:
	make -C src/ clean
	rm -f tst/test.[ch] tst/test