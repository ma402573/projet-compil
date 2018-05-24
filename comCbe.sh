#!/bin/bash

yacc -d cbe.y
lex cbe.l
gcc lex.yy.c y.tab.c -o try -ll
