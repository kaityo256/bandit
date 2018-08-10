set encoding utf8
set term png 
set out "result.png"

set xla "Steps"
set yla "Average awards"

set ytics 0.1
set xtics 2000
set yra [0:] 
set style data line
set key above maxrows 1
p "result.dat" t "Random" lw 2\
, "result.dat" u 1:3 t "Greedy" lw 2\
, "result.dat" u 1:4 t "ε-Greedy" lw 2 \
, "result.dat" u 1:5 t "UCB1" lw 2

