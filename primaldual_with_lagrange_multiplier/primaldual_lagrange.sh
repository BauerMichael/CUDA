#!/bin/sh
#
#Script for make and run program
#
#

make

# ./primaldual_lagrange -i "../images/lena.png" -o "../results/lena_lagrange.png" -level 16 -repeats 1000 -nu 0.01 -lambda 0.11 > "../results/lena_lagrange.txt"
# ./primaldual_lagrange -i "../images/lena_noise.png" -o "../results/lena_noise_lagrange.png" -level 16 -repeats 1000 -nu 0.01 -lambda 0.11 > "../results/lena_noise_lagrange.txt"
# ./primaldual_lagrange -i "../images/lena_noisy.png" -o "../results/lena_noisy_lagrange.png" -level 20 -repeats 100000 -nu 0.01 -lambda 0.11 > "../results/lena_noisy_lagrange.txt"
# ./primaldual_lagrange -i "../images/hepburn.png" -o "../results/hepburn_lagrange.png" -level 20 -repeats 1 -nu 0.01 -lambda 0.1 > "../results/hepburn_lagrange.txt"
# ./primaldual_lagrange -i "../images/ladama.png" -o "../results/ladama/ladama_lagrange.png" -level 8 -repeats 10000 -nu 0.01 -lambda 0.1 > "../results/ladama/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/marylin.png" -o "../results/marylin/marylin_lagrange.png" -level 8 -repeats 10000 -nu 0.001 -lambda 0.1 > "../results/marylin/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/synth_gauss.png" -o "../results/synth_gauss/synth_gauss_lagrange.png" -level 8 -repeats 10000 -nu 0.01 -lambda 0.11 > "../results/synth_gauss/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/crack_tip.png" -o "../results/crack_tip/crack_tip_lagrange.png" -level 32 -repeats 10000 -nu 0.01 -lambda 0.1 > "../results/crack_tip/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/synth.png" -o "../results/synth/synth_lagrange.png" -level 16 -repeats 10000 -nu 0.0001 -lambda 0.1 > "../results/synth/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/synth.png" -o "../results/synth/synth_lagrange.png" -level 16 -repeats 100000 -nu 0.0001 -lambda 0.1

par="../results/parameter.txt"
nrj="../results/data.txt"
img="../img/"
res="../results/"
file="synth_gauss"
./primaldual_lagrange -i $img$file".png" -o $res$file"/"$file"_lagrange.png" -data $nrj -parm $par -level 16 -repeats 10000 -nu 0.001 -lambda 0.11
# gnuplot -e "outfile='../results/$file/$file.png'" -e "datafile='../results/data.txt'"

# for file in "synth" "lena" "hepburn" "ladama" "marylin" "synth_gauss" "crack_tip" "inpaint";
# do
# 	.primaldual_lagrange -i $img$file".png" -o $res$file"/"$file"_lagrange.png" -data $nrj -parm $par -level 8 -repeats 1000 -nu 0.001 -lambda 0.1
# done

# ../results/crack_tip/test.sh
# gnuplot ../results/synth/dual_energy_lagrange.gpl
# gnuplot ../results/ladama/dual_energy_lagrange.gpl
# gnuplot ../results/marylin/dual_energy_lagrange.gpl
# gnuplot ../results/synth_gauss/dual_energy_lagrange.gpl
# gnuplot ../results/crack_tip/dual_energy_lagrange.gpl
