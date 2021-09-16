all		:	../myc

y.tab.h y.tab.c :	lang.y
			bison -v -y  -d  lang.y
lex.yy.c	:	lang.l y.tab.h
			flex lang.l 
../myc		:	lex.yy.c y.tab.c Table_des_chaines.h Table_des_symboles.h Table_des_symboles.c Table_des_chaines.c Attribute.c
			gcc -o ../myc lex.yy.c y.tab.c Attribute.c Table_des_symboles.c Table_des_chaines.c
clean		:	
			rm -f 	lex.yy.c *.o y.tab.h y.tab.c ../myc *~ y.output
