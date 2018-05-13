#!/bin/bash

yacc -d cfe.y
lex ANSI-C.l
gcc lex.yy.c y.tab.c -o try -ll
