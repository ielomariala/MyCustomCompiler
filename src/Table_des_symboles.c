/*
 *  Table des symboles.c
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 */

#include "Table_des_symboles.h"
#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

/* The storage structure is implemented as a linked chain */

/* linked element def */

typedef struct elem {
	sid symbol_name;
	attribute symbol_value;
	struct elem * next;
} elem;

/* linked chain initial element */
static elem * storage=NULL;


void free_symbol() {
	elem *tracker = storage;

	while(tracker) {
		if(tracker->symbol_value->block_number == current_block()){
			elem * tmp = tracker;
			//printf("Freeing %s\n", tmp->symbol_value->name);
			tracker = tracker->next;
			if( storage == tmp ){
				storage = tracker;
			}
			free(tmp->symbol_value->name);
			free(tmp->symbol_value);
			free(tmp);
 		}
		else{
			tracker = tracker->next;
		}
	}
}

/* get the symbol value of symb_id from the symbol table */
attribute get_symbol_value(sid symb_id) {
	elem * tracker=storage;

	/* look into the linked list for the symbol value */
	while (tracker) {
		if (tracker -> symbol_name == symb_id) return tracker -> symbol_value; 
		tracker = tracker -> next;
	}
    
	/* if not found does cause an error */
	fprintf(stderr,"Error : symbol %s is not a valid defined symbol\n",(char *) symb_id);
	exit(-1);
};

/* set the value of symbol symb_id to value */
attribute set_symbol_value(sid symb_id,attribute value) {

	elem * tracker;
	
	/* look for the presence of symb_id in storage */
	
	tracker = storage;
	while (tracker) {
		if (tracker -> symbol_name == symb_id) {
			tracker -> symbol_value = value;
			return tracker -> symbol_value;
		}
		tracker = tracker -> next;
	}
	// tracker == NULL
	/* otherwise insert it at head of storage with proper value */
	
	tracker = malloc(sizeof(elem));     
	tracker -> symbol_name = symb_id;                                             
	tracker -> symbol_value = value;
	tracker -> next = storage;         // elem(a)-st(NULL) -------------> elem(b)-elem(a)-(NULL) -------------> elem(c)-elem(b)-elem(a)-NULL 
	storage = tracker;				   //					st = elem(a)				          st = elem(b)
	//printf("Setting %s\n", tracker->symbol_value->name);
	return storage -> symbol_value;
}

