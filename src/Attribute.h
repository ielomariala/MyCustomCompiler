/*
 *  Attribute.h
 *
 *  Created by Janin on 10/2019
 *  Copyright 2018 LaBRI. All rights reserved.
 *
 *  Module for a clean handling of attibutes values
 *
 */

#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H
#define QUEUE_BLOCK_SIZE 255
typedef enum {VOD, INT, FLOAT, FUNC} type; 
// VOD stands for VOID, can't use VOID because it's previously defined as a TOKEN in lang.y .
// Even if we have added type FUNC it will be used only for error handling .
typedef enum {FALSE, TRUE} bool;

struct ATTRIBUTE {
  char * name;
  type type_val;
  int reg_number;

  /* other attribute's fields can goes here */ 
  
  // Booleans (not necessary but why not?)
  // Like in C, for our language: 0 is gonna be FALSE (if used an a boolean context) and everything else is TRUE 
  //bool bool_val; // In order to achieve this: lang.l has been modified !!!

  // Pointers 
  // First idea: have a boolean (bool pointer;): if TRUE then the attribute is a pointer
  // Problem: What if it's a pointer which points to another pointer
  int star_number; // If 0 then the attribute is a type_val variable, if 1 then pointer to a type_var variable, ...

  // Blocks (This is necessary for conditionals and loops)
  int block_number; // Like reg_number, it's the number of the block where the attribute is lastly used

  // Functions
  int lab_number; // Like reg_number, it's the label (in the 3 adress code) of the attribute if it's a function 
  type type_ret;
};

typedef struct ATTRIBUTE * attribute;

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

//attribute op_attribute(attribute x, char* op, attribute y);


/*
Prints the string s on the file test.c for debugging purposes
*/
void debug( char *s);

/*
Checks if x and y have compatible types
*/
int are_types_compatible(attribute x, attribute y);

/*
Declares and increments number of registers
*/
int new_reg(attribute x);

/*
Increments number of labels
*/
int new_lab();

/*
 We intend to use it whenever { is encountered in test.myc, it increments the queue of the blocks (empiler)
*/
int open_block();

/*
 We intend to use it whenever } is encountered in test.myc, it decrements the queue of the blocks (depiler)
*/
int close_block();

/*
Returns the number block where our analysis is at the moment
*/
int current_block();

/*
Searchs for x in the queue blocks. Returns 1 if found, 0 otherwise. 
*/
int search_block(attribute x);

// ------- Debugging Functions --------- 

/*
Concatenates 2 char* without overwritting the first one
*/
char* custom_strcat(char* a, int entier);

char* attribute__get_name(attribute x);

char* attribute__get_type(attribute x);

char* attribute__get_star(attribute x);



#endif

