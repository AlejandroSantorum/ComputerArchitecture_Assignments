#!/bin/bash

# Iinitialize variables
Ninicial=100 #19216 #10000+1024*9 porque P=(19%7)+4=9
Nstep=50 #64
Nfinal=1000 #20240 #10000+1024*10 porque P=(19%7)+4=9
Nrep=50
fDAT=slow_fast_time.dat
fMeans=mean_fast_time_values.dat
fPNG=slow_fast_time.png
M=$(( ((Nfinal-Ninicial)/Nstep)+1 )) # Number of different matrix sizes

# Delete DAT and PNG files
rm -f $fDAT fPNG fMeans

# Generate empty DAT file
touch $fDAT

echo "Running slow and fast programs..."
for((i = 0; i < Nrep ; i += 1)); do
	for ((N = Ninicial, k=0 ; N <= Nfinal ; N += Nstep, k+=1)); do
		echo "N: $N / $Nfinal..."
		# Run slow and fast programs consecutively with matrix size N.
		# For each program, filter the line which contains the execution time
		# and select the third column (exec time value). Saving theese values
		# in variables to write them in a file later
		slowTime=$(./csource/slow $N | grep 'time' | awk '{print $3}')
		fastTime=$(./csource/fast $N | grep 'time' | awk '{print $3}')
		# Writing in file
		echo "$N $slowTime $fastTime" >> $fDAT
	done
done

python3 ./cal_mean_slow_fast.py $fDAT $M $fMeans

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fMeans" using 1:2 with lines lw 2 title "slow", \
     "$fMeans" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
