#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern FILE *fc; // test.c
extern FILE *fh; // test.h

attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  r->star_number = 0;
  r->block_number = current_block();
  return r;
};


void debug(char *s){
  fprintf(fc, "// Debugging:\t %s\n", s);
}

int are_types_compatible(attribute x, attribute y){
  if (x->type_val == y->type_val && x->star_number == y->star_number){
    if (x->star_number == 0){
      return 1;
    }
    else {
      fprintf(stderr,"Can't operate on pointers");
      return 0;
    }
  }
  else {
    fprintf(stderr,"Uncompatible types!");
    return 0;
  }
};




char* custom_strcat(char* a, int entier){
  char b[80];
  sprintf(b, "%d", entier);
  char* concatenated_s = malloc(strlen(a)+strlen(b)+2);
  strcpy(concatenated_s, "");
  strcat(concatenated_s, a);
  strcat(concatenated_s, b);
  return (concatenated_s);
}


static int reg = 1;
int new_reg(attribute x){
  char* s = attribute__get_star(x);
  fprintf(fh,"%s %sr%d;\n",attribute__get_type(x),s,reg);
  free(s);
  return reg++;
};


static int lab = 1;
int new_lab(){
  
  return lab++;
};

// ----- Queue of blocks ------
static int block = 0;

int open_block(){
  block++;
  return current_block();
};

int close_block(){
  block--;
  return current_block();
};


int current_block(){
  return block;
};


int search_block(attribute x){
  if (x->block_number <= current_block()){
    return 1;
  }
  return 0;
};


// --------------- Dubugging Functions ------------------
char* attribute__get_name(attribute x){
  return x->name;
}

char* attribute__get_type(attribute x){
  switch (x->type_val) {
        case VOD: return "void"; break;
        case INT: return "int"; break;
        case FLOAT: return "float"; break;
        default: return "void"; break;
    }
}

char* attribute__get_star(attribute x){
  int i = x->star_number;
  char* s = malloc(sizeof(char)*i+2); // 2 pour \0
  strcpy(s,"");
  int j;
  for(j=0; j<i; j++){
    strcat(s,"*");
  }
  return s;
}



