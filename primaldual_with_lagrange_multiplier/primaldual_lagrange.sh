#!/bin/sh
#
#Script for make and run program
#
#

make

./primaldual_lagrange -i "../images/hepburn.png" -o "../results/hepburn_lagrange.png" -level 20 -repeats 1 -nu 0.01 -lambda 0.1 > "../results/hepburn_lagrange.txt"
# ./primaldual_lagrange -i "../images/ladama.png" -o "../results/ladama/ladama_lagrange.png" -level 8 -repeats 10000 -nu 0.01 -lambda 0.1 > "../results/ladama/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/marylin.png" -o "../results/marylin/marylin_lagrange.png" -level 8 -repeats 10000 -nu 0.001 -lambda 0.1 > "../results/marylin/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/synth_gauss.png" -o "../results/synth_gauss/synth_gauss_lagrange.png" -level 8 -repeats 10000 -nu 0.01 -lambda 0.11 > "../results/synth_gauss/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/crack_tip.png" -o "../results/crack_tip/crack_tip_lagrange.png" -level 16 -repeats 10000 -nu 0.01 -lambda 0.1 > "../results/crack_tip/data_lagrange.txt"
# ./primaldual_lagrange -i "../images/synth.png" -o "../results/synth/synth_lagrange.png" -level 16 -repeats 10000 -nu 0.0001 -lambda 0.1 > "../results/synth/data_lagrange.txt"

# gnuplot ../results/ladama/dual_energy_lagrange.gpl
# gnuplot ../results/marylin/dual_energy_lagrange.gpl
# gnuplot ../results/synth_gauss/dual_energy_lagrange.gpl
# gnuplot ../results/crack_tip/dual_energy_lagrange.gpl
# gnuplot ../results/synth/dual_energy_lagrange.gpl