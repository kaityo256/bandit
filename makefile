all: result.png

result.dat: bandit.rb
	ruby bandit.rb > result.dat

result.png: result.dat
	gnuplot result.plt

.PHONY: clean

clean:
	rm -f result.dat result.png
