#!/bin/bash

Ninicial=50 #2560 #250+250*9
Nstep=10 #16
Nfinal=100 #2750 #250+250*10
Nrep=5
fCachegrind=cachegrind_file_E3.dat
head_lines=30
fData=mult.dat
fMean=meansE3.dat
fPNGcache=mult_cache.png
fPNGtime=mult_time.png
M=$(( ((Nfinal-Ninicial)/Nstep)+1 )) # Number of different matrix sizes

rm -f $fData fMean fPNGtime fPNGcache fCachegrind

for((i = 0 ; i < Nrep ; i += 1)); do
	for((N = Ninicial ; N <= Nfinal ; N += Nstep)); do
		timeNormal=$(valgrind --tool=cachegrind --cachegrind-out-file=$fCachegrind \
					 ./csource/matrix_mult $N | grep 'time' | awk '{print $3}')
		normalMR=$(cg_annotate $fCachegrind | head -n $head_lines | grep 'PROGRAM TOTALS' | awk '{print $5}')
		normalMR="${normalMR//,}"
		normalMW=$(cg_annotate $fCachegrind | head -n $head_lines | grep 'PROGRAM TOTALS' | awk '{print $8}')
		normalMW="${normalMW//,}"
		timeTrans=$(valgrind --tool=cachegrind --cachegrind-out-file=$fCachegrind \
				    ./csource/transMatrix_mult $N | grep 'time' | awk '{print $3}')
		transMR=$(cg_annotate $fCachegrind | head -n $head_lines | grep 'PROGRAM TOTALS' | awk '{print $5}')
		transMR="${transMR//,}"
		transMW=$(cg_annotate $fCachegrind | head -n $head_lines | grep 'PROGRAM TOTALS' | awk '{print $8}')
		transMW="${transMW//,}"

		echo "$N $timeNormal $normalMR $normalMW $timeTrans $transMR $transMW" >> $fData
	done
done

python3 ./cal_mean_matrix_mult.py $fData $M $fMean

echo "Generating plot..."

gnuplot << END_GNUPLOT
set title "Matrix Multiplication Miss Rate"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGtime"
plot "$fMean" using 1:2 with lines lw 2 title "normal", \
     "$fMean" using 1:5 with lines lw 2 title "trans"
replot
quit
END_GNUPLOT
