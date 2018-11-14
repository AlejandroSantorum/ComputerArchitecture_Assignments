#!/bin/bash
Ninicial=19216 #10000+1024*9 porque P=(19%7)+4=9
Nstep=64
Nfinal=20240
M=$(( ((Nfinal-Ninicial)/Nstep)+1 ))

python3 ./cal_mean_matrix_mult.py "prueba.txt" 3 "out.txt"
