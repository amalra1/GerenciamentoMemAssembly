#!/bin/bash

as OperacoesHeap.s -o OperacoesHeap.o
gcc -c testeProfessor.c -o testeProfessor.o
gcc -no-pie -fno-pie OperacoesHeap.o testeProfessor.o -o a -Wall -g