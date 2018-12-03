#!/bin/bash

Ninicial=200 #516 # 512 + P ; P = 4
Nfinal=1000 #1540 # 1024+512+P ; P = 4
step=100 #64
Nrep=1 #5
Cbest=4
fPreData=files/exercise3/preData_grap.dat
fData=files/exercise3/data_graph.dat
fPlotTime=files/exercise3/time.png
fPlotAcc=files/exercise3/speedUp.png

rm -f $fData $fPlotTime $fPlotAcc

for((i = 1 ; i <= Nrep ; i += 1)); do
	for((N = Ninicial ; N <= Nfinal ; N += step)); do
		echo "N = $N/$Nfinal [Rep number = $i]"
		timeS=$(./csource/matrix_mult_serie $N | grep 'time' | awk '{print $3}')
		timeP=$(./csource/matrix_mult_par3 $N $Cbest | grep 'time' | awk '{print $3}')
		echo "$N $timeS $timeP" >> $fPreData
	done
done

python ./pySource/handle_data_e3_2.py $fPreData $Nrep $fData

echo "Generating plots..."
gnuplot << END_GNUPLOT
set title "Standard-Paralellized Mult Vector Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix size (n*n coords)"
set key left top
set grid
set term png
set output "$fPlotTime"
plot "$fData" using 1:2 with lines lw 2 title "Standard", \
	 "$fData" using 1:3 with lines lw 2 title "Parallelized"
set output "$fPlotAcc"
set title "Standard-Paralellized Mult Vector SpeedUp"
set ylabel "Speed Up (adim)"
set xlabel "Matrix size (n*n coords)"
set key left top
set grid
set term png
plot "$fData" using 1:4 with lines lw 2 title "Parallelized speedUp"
replot
quit
END_GNUPLOT

rm -f $fPreData

