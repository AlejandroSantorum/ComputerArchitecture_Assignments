#!/bin/bash

Ninicio=1 #11216 #2000+1024*9
Npaso=1 #64
Nfinal=3 #12240 #2000+1024*10
Nrep=3
file=out.dat
fMedias=medias.dat
f=cache_
M=1024
head_lines=30
grep_string='PROGRAM TOTALS'
fPlotMR=cache_lectura.png
fplotMW=cache_escritura.png

echo "Running script..."
rm -f $fPlotMR fPlotMW file fMedias cache_1024.dat cache_2048.dat cache_4096.dat cache_8192.dat

for((k = 0 ; k < 4 ; k += 1)); do
	media_slowMR=0
	media_slowMW=0
	media_fastMR=0
	media_fastMW=0
	size=$((M*(2**k)))
	for ((i = 0 ; i <= Nrep ; i += 1)); do
		for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
			valgrind --tool=cachegrind --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 \
					 --cachegrind-out-file=$file ./csource/slow $N &>/dev/null
			slowMR=$(cg_annotate $file | head -n $head_lines | grep 'PROGRAM TOTALS' | awk '{print $5}')
			slowMR="${slowMR//,}"
			slowMW=$(cg_annotate $file | head -n $head_lines | grep 'PROGRAM TOTALS' | awk '{print $8}')
			slowMW="${slowMW//,}"
			valgrind --tool=cachegrind --I1=$size,1,64 --D1=$size,1,64 --LL=8388608,1,64 \
					 --cachegrind-out-file=$file ./csource/fast $N &>/dev/null
			fastMR=$(cg_annotate $file | head -n $head_lines | grep 'PROGRAM TOTALS'| awk '{print $5}')
			fastMR="${fastMR//,}"
			fastMW=$(cg_annotate $file | head -n $head_lines | grep 'PROGRAM TOTALS' | awk '{print $8}')
			fastMW="${fastMW//,}"
			echo "$N $slowMR $slowMW $fastMR $fastMW" >> $f$size.dat
			media_slowMR=$((media_slowMR += slowMR))
			media_slowMW=$((media_slowMW += slowMW))
			media_fastMR=$((media_fastMR += fastMR))
			media_fastMW=$((media_fastMW += fastMW))
		done
	done
	media_slowMR=$((media_slowMR /= Nrep*Nfinal))
	media_slowMW=$((media_slowMW /= Nrep*Nfinal))
	media_fastMR=$((media_fastMR /= Nrep*Nfinal))
	media_fastMW=$((media_fastMW /= Nrep*Nfinal))
	echo "$size $media_slowMR $media_slowMW $media_fastMR $media_fastMW" >> $fMedias
done

rm -f $file


#
#echo "Generating plot of read miss rate..."
#gnuplot << END_GNUPLOT
#set title "Slow-Fast Reading Miss Rate"
#set ylabel "Miss rate"
#set xlabel "Cache Size"
#set key right bottom
#set grid
#set term png
#set output "$fPlotMR"
#plot "$f1024Media.dat" using 1:2 with lines lw 2 title "slow", \
#     "$fDAT" using 1:3 with lines lw 2 title "fast"
#replot
#quit
#END_GNUPLOT
